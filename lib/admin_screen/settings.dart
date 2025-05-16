import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: const Text(
        'Settings Dialog - Under Construction',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
