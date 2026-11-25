// Build-time content adapter and structural validator.
//
// Reads the canonical candidate decks in ../content (never modifies them),
// validates them against content/manifest.json, and writes slim runtime
// decks to assets/decks/. Only the fields needed during play are emitted:
// editorial notes, revision history, mime hints, sample clues, source-search
// hints, verification metadata and quality assessments never reach the app.
//
// Usage (from app/):  dart run tool/build_content.dart
// Exit code 1 if any structural problem is found.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _difficulties = {'easy', 'medium', 'hard', 'expert'};

final List<String> errors = [];

/// Output files, written only once every deck has validated.
final Map<String, String> pending = {};

void fail(String id, String message) => errors.add('$id: $message');

String str(Map<String, dynamic> r, String key, String id) {
  final v = r[key];
  if (v is! String || v.trim().isEmpty) {
    fail(id, 'missing or empty "$key"');
    return '';
  }
  return v.trim();
}

List<String> strList(Map<String, dynamic> r, String key, String id, int n) {
  final v = r[key];
  if (v is! List ||
      v.length != n ||
      v.any((e) => e is! String || e.trim().isEmpty)) {
    fail(id, '"$key" must be $n non-empty strings');
    return const [];
  }
  return v.cast<String>().map((e) => e.trim()).toList();
}

String diff(
  Map<String, dynamic> r,
  String key,
  String id,
  Set<String> allowed,
) {
  final d = str(r, key, id);
  if (!allowed.contains(d)) fail(id, 'difficulty "$d" not in $allowed');
  return d;
}

List<Map<String, dynamic>> readJsonl(File f) {
  final out = <Map<String, dynamic>>[];
  final lines = f.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trim().isEmpty) continue;
    try {
      out.add(jsonDecode(lines[i]) as Map<String, dynamic>);
    } catch (e) {
      fail('${f.path}:${i + 1}', 'invalid JSON ($e)');
    }
  }
  return out;
}

void main(List<String> args) {
  final contentDir = Directory(args.isNotEmpty ? args.first : '../content');
  final outDir = Directory('assets/decks')..createSync(recursive: true);
  final manifest =
      jsonDecode(File('${contentDir.path}/manifest.json').readAsStringSync())
          as Map<String, dynamic>;
  final datasets = {
    for (final d in (manifest['datasets'] as List).cast<Map<String, dynamic>>())
      d['game'] as String: d,
  };

  final meta = <String, dynamic>{
    'status': manifest['status'],
    'releaseReady': manifest['releaseReady'],
    'contentLibraryVersion': (manifest['datasets'] as List)
        .cast<Map<String, dynamic>>()
        .map((d) => d['currentGitBlobSha'] ?? d['importedGitBlobSha'] ?? '')
        .join(':'),
    'games': <String, dynamic>{},
  };

  void emit(
    String game,
    String outName,
    List<Map<String, dynamic>> Function(List<Map<String, dynamic>>) adapt,
  ) {
    final ds = datasets[game];
    if (ds == null) {
      fail(game, 'not listed in manifest');
      return;
    }
    final rows = readJsonl(File('${contentDir.path}/${ds['path']}'));
    final expected = ds['cardCount'] as int;
    if (rows.length != expected)
      fail(game, 'expected $expected cards, found ${rows.length}');
    final schema =
        (ds['currentSchemaVersion'] ?? ds['sourceSchemaVersion']) as String;
    final ids = <String>{};
    for (final r in rows) {
      final id = r['cardId'] as String? ?? '?';
      if (!ids.add(id)) fail(id, 'duplicate cardId');
      if (r['gameType'] != game) fail(id, 'gameType ${r['gameType']} != $game');
      if (r['schemaVersion'] != schema)
        fail(id, 'schemaVersion ${r['schemaVersion']} != manifest $schema');
    }
    final cards = adapt(rows);
    final canonicalBytes = File(
      '${contentDir.path}/${ds['path']}',
    ).readAsBytesSync();
    final runtimeBody = jsonEncode(cards);
    final runtimeHash = sha256.convert(utf8.encode(runtimeBody)).toString();
    final canonicalHash = sha256.convert(canonicalBytes).toString();
    pending['${outDir.path}/$outName.json'] = runtimeBody;
    (meta['games'] as Map)[outName] = {
      'cards': cards.length,
      'schemaVersion': schema,
      'canonicalFingerprint': canonicalHash,
      'runtimeFingerprint': runtimeHash,
      'canonicalGitBlobSha':
          ds['currentGitBlobSha'] ?? ds['importedGitBlobSha'],
    };
    stdout.writeln('$outName: ${cards.length} cards (schema $schema)');
  }

  emit(
    'thirty-seconds',
    'sprint',
    (rows) => [
      for (final r in rows)
        () {
          final id = r['cardId'] as String;
          final terms =
              (r['terms'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
          if (terms.length != 5)
            fail(id, 'expected 5 terms, found ${terms.length}');
          final pattern = terms.map((t) => t['termDifficulty']).toList()
            ..sort();
          if (pattern.join(',') != 'easy,easy,hard,medium,medium') {
            fail(
              id,
              'term difficulty pattern $pattern is not 2 easy / 2 medium / 1 hard',
            );
          }
          final seen = <String>{};
          return {
            'id': id,
            'terms': [
              for (final t in terms)
                {
                  't': () {
                    final s = str(t, 'term', id);
                    if (!seen.add(s.toLowerCase()))
                      fail(id, 'duplicate term "$s"');
                    return s;
                  }(),
                  'd': diff(t, 'termDifficulty', id, {
                    'easy',
                    'medium',
                    'hard',
                  }),
                  if (t['contextLabel'] is String &&
                      (t['contextLabel'] as String).trim().isNotEmpty)
                    'c': (t['contextLabel'] as String).trim(),
                },
            ],
          };
        }(),
    ],
  );

  emit(
    'charades',
    'charades',
    (rows) => [
      for (final r in rows)
        {
          'id': r['cardId'],
          'p': str(r, 'prompt', r['cardId'] as String),
          'c': str(r, 'playableCategory', r['cardId'] as String),
          'd': diff(r, 'difficulty', r['cardId'] as String, {
            'easy',
            'medium',
            'hard',
          }),
        },
    ],
  );

  emit(
    'trivia',
    'trivia',
    (rows) => [
      for (final r in rows)
        () {
          final id = r['cardId'] as String;
          final a = str(r, 'correctAnswer', id);
          final x = strList(r, 'distractors', id, 3);
          final all = {a.toLowerCase(), ...x.map((e) => e.toLowerCase())};
          if (all.length != 4)
            fail(id, 'answer options are not four distinct values');
          return {
            'id': id,
            'q': str(r, 'question', id),
            'a': a,
            'x': x,
            'e': str(r, 'explanation', id),
            'd': diff(r, 'difficulty', id, _difficulties),
            'c': str(r, 'productionCategory', id),
          };
        }(),
    ],
  );

  emit(
    'forbidden-words',
    'forbidden',
    (rows) => [
      for (final r in rows)
        () {
          final id = r['cardId'] as String;
          final clues = strList(r, 'forbiddenClues', id, 5);
          if (clues.map((e) => e.toLowerCase()).toSet().length != clues.length)
            fail(id, 'duplicate forbidden clue');
          return {
            'id': id,
            't': str(r, 'targetWord', id),
            'f': clues,
            'd': diff(r, 'difficulty', id, {'easy', 'medium', 'hard'}),
            'c': str(r, 'productionCategory', id),
          };
        }(),
    ],
  );

  pending['${outDir.path}/meta.json'] = jsonEncode(meta);

  if (errors.isNotEmpty) {
    stderr.writeln('Content validation failed (${errors.length} problems):');
    for (final e in errors.take(50)) {
      stderr.writeln('  - $e');
    }
    exit(1);
  }
  pending.forEach((path, body) => File(path).writeAsStringSync(body));
  stdout.writeln('Content validation passed.');
}
