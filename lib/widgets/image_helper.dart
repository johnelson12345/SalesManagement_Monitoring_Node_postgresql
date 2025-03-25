import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  static Widget buildImage(String? base64String, {double width = 50, double height = 50}) {
    if (base64String == null || base64String.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey, size: 40);
    }

    try {
      Uint8List bytes = base64Decode(base64String);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, color: Colors.red, size: 40),
        ),
      );
    } catch (e) {
      print("Error decoding base64: $e");
      return const Icon(Icons.broken_image, color: Colors.red, size: 40);
    }
  }
}
