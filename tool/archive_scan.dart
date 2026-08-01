import 'dart:io';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln(
      'Usage: dart run tool/archive_scan.dart <portable-source.zip>',
    );
    exitCode = 64;
    return;
  }
  final archive = File(arguments.single).absolute;
  if (!archive.existsSync()) {
    stderr.writeln('Portable archive is missing: ${archive.path}');
    exitCode = 1;
    return;
  }

  final listing = await Process.run('tar', ['-tf', archive.path]);
  if (listing.exitCode != 0) {
    stderr.writeln('Unable to list the portable archive safely.');
    exitCode = 1;
    return;
  }
  final entries = (listing.stdout as String)
      .split(RegExp(r'[\r\n]+'))
      .where((entry) => entry.isNotEmpty)
      .map((entry) => entry.replaceAll('\\', '/'))
      .toList(growable: false);
  final problems = <String>[];
  final forbiddenPath = RegExp(
    r'(^|/)(\.dart_tool|build|coverage|Pods|DerivedData)(/|$)|'
    r'(^|/)ios/Flutter/ephemeral(/|$)|'
    r'(^|/)\.flutter-plugins-dependencies$|'
    r'(^|/)android/local\.properties$|'
    r'(^|/)ios/Flutter/(Generated\.xcconfig|flutter_export_environment\.sh)$|'
    r'\.iml$',
    caseSensitive: false,
  );
  for (final entry in entries) {
    final segments = entry.split('/');
    if (entry.startsWith('/') ||
        entry.startsWith('\\') ||
        RegExp(r'^[A-Za-z]:').hasMatch(entry) ||
        segments.contains('..')) {
      problems.add('Unsafe archive entry: $entry');
    }
    if (forbiddenPath.hasMatch(entry)) {
      problems.add('Machine-generated archive entry: $entry');
    }
  }
  if (problems.isNotEmpty) {
    stderr.writeln(problems.join('\n'));
    exitCode = 1;
    return;
  }

  final extraction = await Directory.systemTemp.createTemp(
    'waflo-mobile-archive-scan-',
  );
  try {
    final extracted = await Process.run('tar', [
      '-xf',
      archive.path,
      '-C',
      extraction.path,
    ]);
    if (extracted.exitCode != 0) {
      stderr.writeln('Portable archive extraction failed.');
      exitCode = 1;
      return;
    }
    final machineText = <RegExp>[
      RegExp(
        RegExp.escape(
          r'C:'
          r'\Users\',
        ),
        caseSensitive: false,
      ),
      RegExp(r'/Users/[^/<\s]+/', caseSensitive: false),
      RegExp(r'/home/[^/<\s]+/', caseSensitive: false),
      RegExp(r'flutter\.sdk\s*=', caseSensitive: false),
      RegExp(r'sdk\.dir\s*=', caseSensitive: false),
      RegExp(r'FLUTTER_ROOT\s*=', caseSensitive: false),
      RegExp(r'ANDROID_HOME\s*=', caseSensitive: false),
    ];
    await for (final entity in extraction.list(recursive: true)) {
      if (entity is! File || _isBinary(entity.path)) continue;
      String text;
      try {
        text = await entity.readAsString();
      } on FormatException {
        continue;
      }
      if (machineText.any((pattern) => pattern.hasMatch(text))) {
        final relative = entity.path.substring(extraction.path.length + 1);
        problems.add('Machine-specific absolute path in: $relative');
      }
    }
  } finally {
    await extraction.delete(recursive: true);
  }

  if (problems.isNotEmpty) {
    stderr.writeln(problems.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Archive scan passed: ${entries.length} entries; exclusions, extraction, and absolute-path checks are clean.',
  );
}

bool _isBinary(String path) => RegExp(
  r'\.(png|jpg|jpeg|gif|webp|ico|zip|gz|jar|apk|aab|ttf|otf|pdf)$',
  caseSensitive: false,
).hasMatch(path);
