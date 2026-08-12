import 'dart:io';

const _presentationRoots = <String>[
  'lib/app',
  'lib/core/design_system',
  'lib/features',
];
const _staleColors = <String>[
  '#006B55',
  '#073F34',
  '#8EDCC5',
  '#DDF5EC',
  '#F7F6F1',
  '#B45F00',
  '#BA2D27',
];
const _staleTypography = <String>[
  'WafloSans',
  'WafloArabic',
  'Roboto',
  'NotoNaskh',
];

void main() {
  final failures = <String>[];
  for (final root in _presentationRoots) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final text = entity.readAsStringSync();
      for (final stale in [..._staleColors, ..._staleTypography]) {
        if (text.toUpperCase().contains(stale.toUpperCase())) {
          failures.add('${entity.path}: stale brand value $stale');
        }
      }
    }
  }
  if (failures.isNotEmpty) {
    stderr.writeln(failures.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln('Brand lint passed: official presentation identity only.');
}
