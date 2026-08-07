import 'package:waflo_staff/core/errors/app_failure.dart';

String strictMobileSemanticVersion(String packageVersion) {
  final separator = packageVersion.indexOf('+');
  final version = separator < 0
      ? packageVersion
      : packageVersion.substring(0, separator);
  final buildMetadata = separator < 0
      ? null
      : packageVersion.substring(separator + 1);
  if (buildMetadata != null &&
      (buildMetadata.isEmpty ||
          !RegExp(r'^[0-9A-Za-z.-]+$').hasMatch(buildMetadata))) {
    throw const ConfigurationFailure(['APP_VERSION_INVALID']);
  }
  final match = RegExp(
    r'^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$',
  ).firstMatch(version);
  if (match == null) {
    throw const ConfigurationFailure(['APP_VERSION_INVALID']);
  }
  for (var index = 1; index <= 3; index += 1) {
    final component = int.tryParse(match.group(index)!);
    if (component == null || component > 999999) {
      throw const ConfigurationFailure(['APP_VERSION_INVALID']);
    }
  }
  return version;
}

bool isStrictMobileSemanticVersion(String value) {
  try {
    return strictMobileSemanticVersion(value) == value;
  } on ConfigurationFailure {
    return false;
  }
}
