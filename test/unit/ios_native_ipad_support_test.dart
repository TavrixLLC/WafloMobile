import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const runnerConfigurations = {
    'Debug',
    'Profile',
    'Release',
    'Debug-development',
    'Profile-development',
    'Release-development',
    'Debug-staging',
    'Profile-staging',
    'Release-staging',
    'Debug-production',
    'Profile-production',
    'Release-production',
  };

  test('every Runner configuration targets native iPhone and iPad', () {
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    final runnerList = RegExp(
      r'/\* Build configuration list for PBXNativeTarget "Runner" \*/ = \{.*?buildConfigurations = \((.*?)\);',
      dotAll: true,
    ).firstMatch(project);
    expect(runnerList, isNotNull);

    final entries = RegExp(r'([A-F0-9]{24}) /\* ([^*]+) \*/')
        .allMatches(runnerList!.group(1)!)
        .map((match) {
          return (id: match.group(1)!, name: match.group(2)!.trim());
        })
        .toList(growable: false);
    expect(entries.map((entry) => entry.name).toSet(), runnerConfigurations);

    for (final entry in entries) {
      final block = RegExp(
        '${RegExp.escape(entry.id)} /\\* ${RegExp.escape(entry.name)} \\*/ = \\{(.*?)\\n\\t\\t\\};',
        dotAll: true,
      ).firstMatch(project);
      expect(block, isNotNull, reason: 'Missing ${entry.name} target block');
      expect(
        block!.group(1),
        contains('TARGETED_DEVICE_FAMILY = "1,2";'),
        reason: '${entry.name} must build a universal iPhone/iPad app',
      );
    }
  });

  test('Info.plist allows native iPad orientations and multitasking', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(_orientationValues(plist, 'UISupportedInterfaceOrientations'), {
      'UIInterfaceOrientationPortrait',
      'UIInterfaceOrientationLandscapeLeft',
      'UIInterfaceOrientationLandscapeRight',
    }, reason: 'The existing iPhone orientation contract must stay unchanged');
    expect(_orientationValues(plist, 'UISupportedInterfaceOrientations~ipad'), {
      'UIInterfaceOrientationPortrait',
      'UIInterfaceOrientationPortraitUpsideDown',
      'UIInterfaceOrientationLandscapeLeft',
      'UIInterfaceOrientationLandscapeRight',
    });
    expect(plist, isNot(contains('<key>UIRequiresFullScreen</key>')));
    expect(plist, isNot(contains('<key>UIDeviceFamily</key>')));
    expect(plist, contains('<key>UILaunchStoryboardName</key>'));
  });

  test('camera permission is configured and localized on iOS', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final podfile = File('ios/Podfile').readAsStringSync();
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();

    expect(plist, contains('<key>NSCameraUsageDescription</key>'));
    expect(podfile, contains('PERMISSION_CAMERA=1'));
    for (final locale in ['en', 'ar', 'ckb', 'ku']) {
      final strings = File(
        'ios/Runner/$locale.lproj/InfoPlist.strings',
      ).readAsStringSync();
      expect(strings, contains('"NSCameraUsageDescription"'));
      expect(project, contains('$locale.lproj/InfoPlist.strings'));
    }
  });

  test('Android declares camera without microphone or media permissions', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.CAMERA'));
    expect(manifest, isNot(contains('android.permission.RECORD_AUDIO')));
    expect(manifest, isNot(contains('android.permission.READ_MEDIA')));
    expect(
      manifest,
      isNot(contains('android.permission.READ_EXTERNAL_STORAGE')),
    );
    expect(
      manifest,
      isNot(contains('android.permission.WRITE_EXTERNAL_STORAGE')),
    );
  });

  test(
    'flavor schemes still map to their Debug Profile and Release configs',
    () {
      for (final flavor in ['development', 'staging', 'production']) {
        final scheme = File(
          'ios/Runner.xcodeproj/xcshareddata/xcschemes/$flavor.xcscheme',
        ).readAsStringSync();
        expect(scheme, contains('buildConfiguration="Debug-$flavor"'));
        expect(scheme, contains('buildConfiguration="Profile-$flavor"'));
        expect(scheme, contains('buildConfiguration="Release-$flavor"'));
      }
    },
  );
}

Set<String> _orientationValues(String plist, String key) {
  final array = RegExp(
    '<key>${RegExp.escape(key)}</key>\\s*<array>(.*?)</array>',
    dotAll: true,
  ).firstMatch(plist);
  expect(array, isNotNull, reason: '$key is missing');
  return RegExp(
    r'<string>([^<]+)</string>',
  ).allMatches(array!.group(1)!).map((match) => match.group(1)!).toSet();
}
