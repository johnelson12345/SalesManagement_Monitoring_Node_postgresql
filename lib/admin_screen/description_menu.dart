import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/menu_model.dart';

class DescriptionMenuDialog extends StatelessWidget {
  final Menu menu;

  const DescriptionMenuDialog({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (menu.image != null && menu.image!.isNotEmpty) {
      try {
        imageBytes = base64Decode(menu.image!);
      } catch (e) {
        imageBytes = null;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menu.menuname,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              const SizedBox(height: 12),
              Text(
                "Price: ₱${menu.price.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                "Description:",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                menu.description ?? "No description available.",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
