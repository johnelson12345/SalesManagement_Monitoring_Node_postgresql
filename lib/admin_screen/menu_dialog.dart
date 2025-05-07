import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:sales_managementv5/model/category_model.dart';
import 'package:sales_managementv5/model/menu_model.dart';
import 'dart:convert';

class MenuDialog extends StatefulWidget {
  final Menu? menu;
  final List<Category> categories;
  final Function(Menu) onSave;

  const MenuDialog({
    Key? key,
    this.menu,
    required this.categories,
    required this.onSave,
  }) : super(key: key);

  @override
  _MenuDialogState createState() => _MenuDialogState();
}

class _MenuDialogState extends State<MenuDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  String? _selectedCategoryId;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      _nameController.text = widget.menu!.menuname;
      _selectedCategoryId = widget.menu!.categoryid.toString();
      _descriptionController.text = widget.menu!.description ?? '';
      _priceController.text = widget.menu!.price.toString();
      _statusController.text = widget.menu!.status;
    } else {
      _statusController.text = "available";
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path.replaceAll('\\', '/'));
      });
    }
  }

  Future<String> compressAndConvertToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

    if (image != null) {
      img.Image resized = img.copyResize(image, width: 300);
      List<int> compressedBytes = img.encodeJpg(resized, quality: 75);
      return base64Encode(compressedBytes);
    }

    return base64Encode(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    String? base64Image = widget.menu?.image;
    Uint8List? decodedImage = base64Image != null ? base64Decode(base64Image) : null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(widget.menu == null ? "Add Menu" : "Edit Menu"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Menu Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
              items: widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category.id.toString(),
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Price", border: OutlineInputBorder()),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _statusController.text.isNotEmpty ? _statusController.text : "available",
              decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
              items: ["available", "soldout"].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _statusController.text = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 100)
            else if (decodedImage != null)
              Image.memory(decodedImage, height: 100),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                await _pickImage();
              },
              icon: const Icon(Icons.image),
              label: const Text("Choose Image"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.isEmpty ||
                _priceController.text.isEmpty ||
                _statusController.text.isEmpty) return;

            String? base64Image;
            if (_selectedImage != null) {
              base64Image = await compressAndConvertToBase64(_selectedImage!);
            } else if (widget.menu != null) {
              base64Image = widget.menu!.image;
            }

            final menu = Menu(
              id: widget.menu?.id,
              menuname: _nameController.text,
              categoryid: int.tryParse(_selectedCategoryId ?? '') ?? 0,
              description: _descriptionController.text,
              price: double.parse(_priceController.text),
              status: _statusController.text,
              image: base64Image,
            );

            widget.onSave(menu);
            Navigator.pop(context);
          },
          child: Text(widget.menu == null ? "Add" : "Update"),
        ),
      ],
    );
  }
}
