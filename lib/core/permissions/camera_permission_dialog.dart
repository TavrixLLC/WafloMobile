import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';

Future<void> showCameraPermissionSettingsDialog(
  BuildContext context, {
  required Future<void> Function() onOpenSettings,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) {
    final strings = AppLocalizations.of(dialogContext);
    return AlertDialog(
      key: const Key('camera-permission-settings-dialog'),
      icon: const Icon(Icons.no_photography_outlined),
      title: Text(strings.cameraPermissionPermanentlyDeniedTitle),
      content: Text(strings.cameraPermissionPermanentlyDeniedBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(strings.notNow),
        ),
        FilledButton(
          key: const Key('open-camera-settings'),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            unawaited(onOpenSettings());
          },
          child: Text(strings.openSettings),
        ),
      ],
    );
  },
);
