import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final result = await Process.run('git', [
    'ls-files',
    '-co',
    '--exclude-standard',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln('Unable to enumerate repository files safely.');
    exitCode = 1;
    return;
  }
  final paths = (result.stdout as String)
      .split(RegExp(r'[\r\n]+'))
      .where((path) => path.isNotEmpty)
      .toList(growable: false);
  final patterns = <RegExp>[
    RegExp(r'[A-Za-z]:[\\/]Users[\\/][^<\\/\s]+[\\/]', caseSensitive: false),
    RegExp(
      '/'
      'Users/'
      r'[^/<\s]+/',
      caseSensitive: false,
    ),
    RegExp(
      '/'
      'home/'
      r'[^/<\s]+/',
      caseSensitive: false,
    ),
    RegExp(r'(?:flutter\.sdk|sdk\.dir)\s*=', caseSensitive: false),
    RegExp(
      r'(?:FLUTTER_ROOT|ANDROID_HOME|ANDROID_SDK_ROOT)\s*=',
      caseSensitive: false,
    ),
    RegExp(
      r'[A-Za-z]:[\\/](?:[^\r\n]+[\\/])?flutter[\\/]bin[\\/]',
      caseSensitive: false,
    ),
    RegExp(
      r'[A-Za-z]:[\\/](?:[^\r\n]+[\\/])?Android[\\/]Sdk[\\/]',
      caseSensitive: false,
    ),
    RegExp(
      '/(?:opt|usr/local)/flutter/'
      'bin/',
      caseSensitive: false,
    ),
  ];
  final problems = <String>[];
  for (final path in paths) {
    if (_isBinary(path)) continue;
    final file = File(path);
    if (!file.existsSync()) continue;
    final contents = utf8.decode(
      await file.readAsBytes(),
      allowMalformed: true,
    );
    if (patterns.any((pattern) => pattern.hasMatch(contents))) {
      problems.add(path.replaceAll(r'\', '/'));
    }
  }
  if (problems.isNotEmpty) {
    stderr.writeln(
      'Machine-specific absolute path or local SDK assignment found in:\n'
      '${problems.join('\n')}',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Absolute-path scan passed: ${paths.length} files contain no local '
    'user-home or SDK paths.',
  );
}

bool _isBinary(String path) => RegExp(
  r'\.(png|jpg|jpeg|gif|webp|ico|zip|gz|jar|apk|aab|ttf|otf|pdf)$',
  caseSensitive: false,
).hasMatch(path);
