// Production web build with offline support.
//
//   dart run tool/build_web.dart
//
// 1. Regenerates and validates the runtime decks from ../content.
// 2. Builds the Flutter web app with CanvasKit served locally
//    (--no-web-resources-cdn), so nothing is fetched from a CDN at runtime.
// 3. Writes build/web/sw.js: a cache-first service worker whose precache list
//    is the build output (minus files the JS build never loads), versioned by
//    a content hash so a new deploy replaces the old cache.
import 'dart:convert';
import 'dart:io';

Future<void> run(String exe, List<String> args) async {
  stdout.writeln('> $exe ${args.join(' ')}');
  final p = await Process.start(exe, args, runInShell: true, mode: ProcessStartMode.inheritStdio);
  final code = await p.exitCode;
  if (code != 0) exit(code);
}

/// FNV-1a over all precached bytes: cheap, dependency-free cache version.
int fnv(List<int> bytes, int h) {
  for (final b in bytes) {
    h ^= b;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

Future<void> main(List<String> args) async {
  await run('dart', ['run', 'tool/build_content.dart']);
  await run('flutter', ['build', 'web', '--release', '--no-web-resources-cdn', '--no-wasm-dry-run', ...args]);

  final root = Directory('build/web');
  final files = <String>[];
  var hash = 0x811C9DC5;
  final entries = root.listSync(recursive: true).whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in entries) {
    final rel = f.path.substring(root.path.length + 1).replaceAll('\\', '/');
    final skip = rel == 'sw.js' ||
        rel == 'flutter_service_worker.js' ||
        rel.endsWith('.map') ||
        rel.endsWith('.symbols') ||
        rel == 'assets/NOTICES' ||
        // Engine binaries: the page reports the variant it actually loaded
        // (CanvasKit, or its smaller Chromium build) and the worker caches
        // just that — see web/flutter_bootstrap.js.
        rel.startsWith('canvaskit/') ||
        rel == 'version.json';
    if (skip) continue;
    files.add(rel);
    hash = fnv(f.readAsBytesSync(), hash);
  }
  final version = hash.toRadixString(16).padLeft(8, '0');
  final template = File('web_sw/sw.template.js').readAsStringSync();
  File('build/web/sw.js').writeAsStringSync(template
      .replaceAll('__VERSION__', version)
      .replaceAll('__PRECACHE__', const JsonEncoder.withIndent('  ').convert(['./', ...files])));
  final bytes = entries.where((f) => files.contains(f.path.substring(root.path.length + 1).replaceAll('\\', '/')))
      .fold<int>(0, (a, f) => a + f.lengthSync());
  stdout.writeln('sw.js: ${files.length} files precached (${(bytes / 1048576).toStringAsFixed(1)} MB), version $version');
}
