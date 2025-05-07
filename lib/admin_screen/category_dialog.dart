import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/category_model.dart';

typedef OnCategorySaved = Future<void> Function(Category category);

class CategoryDialog extends StatefulWidget {
  final Category? category;
  final OnCategorySaved onSave;

  const CategoryDialog({Key? key, this.category, required this.onSave}) : super(key: key);

  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _codeController = TextEditingController(text: widget.category?.code ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(widget.category == null ? "Add Category" : "Edit Category"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(labelText: "Code", border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.isEmpty || _codeController.text.isEmpty) return;
            final newCategory = Category(
              id: widget.category?.id,
              name: _nameController.text,
              code: _codeController.text,
            );
            await widget.onSave(newCategory);
            Navigator.pop(context);
          },
          child: Text(widget.category == null ? "Add" : "Update"),
        ),
      ],
    );
  }
}
