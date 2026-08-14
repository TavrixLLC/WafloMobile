import 'dart:io';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln('Usage: dart run tool/verify_local_demo_apk.dart <apk>');
    exitCode = 64;
    return;
  }
  final apk = File(arguments.single).absolute;
  if (!apk.existsSync()) {
    stderr.writeln('APK is missing: ${apk.path}');
    exitCode = 1;
    return;
  }

  final extraction = await Directory.systemTemp.createTemp(
    'waflo-local-demo-apk-',
  );
  try {
    final result = Platform.isWindows
        ? await Process.run('tar', ['-xf', apk.path, '-C', extraction.path])
        : await Process.run('unzip', ['-q', apk.path, '-d', extraction.path]);
    if (result.exitCode != 0) {
      stderr.writeln('Unable to extract APK for local-demo inspection.');
      exitCode = 1;
      return;
    }

    const forbidden = <String>[
      'local-demo-scenario-',
      'simulate-valid-qr',
      '/demo-scenarios',
      '2468',
      'WAFLO_LOCAL_DEMO_CODE',
      'DebugManualCodeIntentResolver',
    ];
    final hits = <String>[];
    final libraries = extraction
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.uri.pathSegments.last == 'libapp.so');
    for (final library in libraries) {
      final bytes = library.readAsBytesSync();
      for (final needle in forbidden) {
        if (_containsAscii(bytes, needle)) hits.add(needle);
      }
    }
    if (hits.isNotEmpty) {
      stderr.writeln(
        'Release APK contains forbidden LOCAL_DEMO markers: '
        '${hits.toSet().join(', ')}',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln(
      'Release APK excludes local scenario routes, scanner simulations, and '
      'the local App Lock fixture PIN.',
    );
  } finally {
    if (extraction.existsSync()) extraction.deleteSync(recursive: true);
  }
}

bool _containsAscii(List<int> bytes, String needle) {
  final pattern = needle.codeUnits;
  for (var start = 0; start <= bytes.length - pattern.length; start++) {
    var matches = true;
    for (var offset = 0; offset < pattern.length; offset++) {
      if (bytes[start + offset] != pattern[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}
