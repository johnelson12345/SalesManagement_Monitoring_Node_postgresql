import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/category_model.dart';
import 'package:sales_managementv5/services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_filterCategories);
  }

  void _loadCategories() async {
    try {
      final categories = await CategoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _filteredCategories = categories;
        });
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  void _filterCategories() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _categories
          .where((category) => category.name.toLowerCase().contains(query)||
           category.code.toLowerCase().contains(query))
          .toList();
    });
  }

  void _showCategoryDialog({Category? category}) {
    if (category != null) {
      _nameController.text = category.name;
      _codeController.text = category.code;
    } else {
      _nameController.clear();
      _codeController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(category == null ? "Add Category" : "Edit Category"),
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
                if (category == null) {
                  await CategoryService.addCategory(
                    Category(name: _nameController.text, code: _codeController.text),
                  );
                } else {
                  await CategoryService.updateCategory(
                    category.id!,
                    Category(name: _nameController.text, code: _codeController.text),
                  );
                }
                _loadCategories();
                Navigator.pop(context);
              },
              child: Text(category == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(int id) async {
    await CategoryService.deleteCategory(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Category"),
              onPressed: () => _showCategoryDialog(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search categories...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredCategories.isEmpty
                  ? const Center(child: Text("No categories available"))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Horizontal scrolling
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, 
                            child: DataTable(
                              headingRowColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey), // Set header color
                              columnSpacing: 500,
                              border: TableBorder.all(width: 1, color: Colors.grey),
                              columns: const [
                                DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                              ],
                              rows: _filteredCategories.map((category) {
                                return DataRow(cells: [
                                  DataCell(Text(category.name)),
                                  DataCell(Text(category.code)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showCategoryDialog(category: category),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteCategory(category.id!),
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        )
            ),
          ],
        ),
      ),
    );
  }
}