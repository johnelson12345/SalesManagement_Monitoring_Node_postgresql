import 'package:flutter/material.dart';

class CloseButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const CloseButtonWidget({Key? key, this.onPressed, this.label = "Close"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
