// Runtime decks: right counts, playable shape, no editorial metadata.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  final manifest = jsonDecode(File('../content/manifest.json').readAsStringSync()) as Map<String, dynamic>;
  int expected(String game) =>
      ((manifest['datasets'] as List).firstWhere((d) => d['game'] == game) as Map)['cardCount'] as int;

  test('decks match the canonical manifest (2,300 cards)', () {
    final lib = realLibrary();
    expect(lib.sprint.length, expected('thirty-seconds'));
    expect(lib.charades.length, expected('charades'));
    expect(lib.trivia.length, expected('trivia'));
    expect(lib.forbidden.length, expected('forbidden-words'));
    expect(lib.sprint.length + lib.charades.length + lib.trivia.length + lib.forbidden.length, 2300);
  });

  test('card IDs are preserved from the canonical decks', () {
    final canonical = File('../content/trivia/cards.jsonl')
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty)
        .map((l) => (jsonDecode(l) as Map)['cardId'])
        .toSet();
    expect(realLibrary().trivia.keys.toSet(), canonical);
  });

  test('editorial, verification and hint fields never reach the runtime decks', () {
    const banned = [
      'editorialNotes', 'mimeHints', 'sampleValidClues', 'solvabilityCheck', 'sourceSearchHint',
      'verification', 'qualityAssessment', 'editorialAssessment', 'factCheckStatus', 'revision',
      'balanceMetrics', 'editorialMetadata', 'pathways',
    ];
    // Check object keys, not raw text: card content may legitimately contain
    // these words (e.g. the forbidden clue "verification").
    Set<String> keysOf(Object? node) => switch (node) {
          Map m => {...m.keys.cast<String>(), for (final v in m.values) ...keysOf(v)},
          List l => {for (final v in l) ...keysOf(v)},
          _ => <String>{},
        };
    for (final f in ['sprint', 'charades', 'trivia', 'forbidden']) {
      final keys = keysOf(jsonDecode(File('assets/decks/$f.json').readAsStringSync()));
      for (final b in banned) {
        expect(keys.contains(b), isFalse, reason: '$b leaked into $f.json');
      }
      expect(keys.length, lessThanOrEqualTo(8), reason: 'runtime cards stay slim: $keys');
    }
  });

  test('every playable card has the fields its game needs', () {
    final lib = realLibrary();
    for (final c in lib.sprint.values) {
      expect(c.terms.length, 5);
    }
    for (final c in lib.trivia.values) {
      expect(c.options.toSet().length, 4, reason: c.id);
      expect(c.explanation, isNotEmpty);
    }
    for (final c in lib.forbidden.values) {
      expect(c.clues.length, 5);
    }
    for (final c in lib.charades.values) {
      expect(c.prompt, isNotEmpty);
    }
  });
}
