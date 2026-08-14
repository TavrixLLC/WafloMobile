import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln(
      'Usage: dart run tool/verify_lovable_design_pack.dart <directory-or-zip>',
    );
    exitCode = 64;
    return;
  }

  final input = FileSystemEntity.typeSync(arguments.single);
  Directory? temporary;
  late final Directory root;
  if (input == FileSystemEntityType.directory) {
    root = Directory(arguments.single);
  } else if (input == FileSystemEntityType.file &&
      arguments.single.toLowerCase().endsWith('.zip')) {
    temporary = await Directory.systemTemp.createTemp('waflo-design-pack-');
    final extracted = await Process.run('tar', [
      '-xf',
      File(arguments.single).absolute.path,
      '-C',
      temporary.path,
    ]);
    if (extracted.exitCode != 0) {
      stderr.writeln('Unable to inspect design-pack ZIP.');
      exitCode = 1;
      return;
    }
    final extractedEntries = temporary.listSync();
    root = extractedEntries.length == 1 && extractedEntries.single is Directory
        ? extractedEntries.single as Directory
        : temporary;
  } else {
    stderr.writeln('Design pack not found: ${arguments.single}');
    exitCode = 1;
    return;
  }

  try {
    final failures = <String>[];
    final files = root.listSync(recursive: true).whereType<File>();
    for (final file in files) {
      final relative = file.path
          .substring(root.path.length)
          .replaceAll('\\', '/');
      final lower = relative.toLowerCase();
      if (RegExp(
        r'(^|/)(\.env($|\.)|[^/]+\.(jks|p12|p8|pem|keystore)$)',
      ).hasMatch(lower)) {
        failures.add('$relative: forbidden secret-bearing file type');
        continue;
      }
      final bytes = file.readAsBytesSync();
      if (bytes.length > 12 * 1024 * 1024) continue;
      final text = latin1.decode(bytes, allowInvalid: true);
      final checks = <RegExp>[
        RegExp(r'-----BEGIN [A-Z ]*PRIVATE KEY-----'),
        RegExp(r'Authorization:\s*(Bearer|Device)\s+\S+', caseSensitive: false),
        RegExp(
          r'(accessToken|refreshToken|client_secret|api[_-]?key|password|secret)\s*[:=]\s*["\x27][^<\s][^"\x27]{5,}["\x27]',
          caseSensitive: false,
        ),
        RegExp(r'waflo-pair-v1\.[A-Za-z0-9_-]+\.'),
        RegExp(r'[A-Za-z]:\\Users\\[^\\\s]+', caseSensitive: false),
        RegExp(
          '/'
          'Users/'
          r'[^/\s]+|/'
          'home/'
          r'[^/\s]+',
        ),
      ];
      for (final pattern in checks) {
        if (pattern.hasMatch(text)) {
          failures.add('$relative: matched ${pattern.pattern}');
        }
      }
    }

    const required = <String>[
      '00_README.md',
      '01_PRODUCT_OVERVIEW.md',
      '09_SCANNER_UX.md',
      '16_LOVABLE_INSTRUCTIONS.md',
      '17_SECURITY_BOUNDARY.md',
      'SECURITY-SCAN.md',
    ];
    for (final name in required) {
      if (!File('${root.path}${Platform.pathSeparator}$name').existsSync()) {
        failures.add('$name: required pack document missing');
      }
    }

    if (failures.isNotEmpty) {
      stderr.writeln('Lovable design-pack security verification failed:');
      for (final failure in failures) {
        stderr.writeln('- $failure');
      }
      exitCode = 1;
      return;
    }
    stdout.writeln(
      'Lovable design-pack security verified: no known credentials, key material, '
      'environment files, real pairing payloads, or user-home paths.',
    );
  } finally {
    temporary?.deleteSync(recursive: true);
  }
}
