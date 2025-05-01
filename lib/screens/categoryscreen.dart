import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/category_model.dart';
import 'package:sales_managementv5/services/category_service.dart';
import 'package:sales_managementv5/widgets/confirmation_delete_dialog.dart';

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
          .where((category) =>
              category.name.toLowerCase().contains(query) ||
              category.code.toLowerCase().contains(query))
          .toList();
    });
  }

void _showCategoryDialog(Category? category) {
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
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Code",
                border: OutlineInputBorder(),
              ),
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
        title: const Text(
          "Categories",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search categories...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white, size: 38),
                  label: const Text("Add Category", style: TextStyle(color: Colors.white)),
                  onPressed: () => _showCategoryDialog(null),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF203A43),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredCategories.isEmpty
                  ? const Center(child: Text("No categories available"))
                  : Container(
                      width: double.infinity,
                      child: PaginatedDataTable(
                        header: const Text("Categories", style: TextStyle(fontSize: 20)),
                        rowsPerPage: 5,
                        columns: const [
                          DataColumn(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Code", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      source: _CategoryDataSource(
                        _filteredCategories,
                        _showCategoryDialog,
                        _deleteCategory,
                        context,
                      ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDataSource extends DataTableSource {
  final List<Category> categories;
  final Function(Category?) showCategoryDialog;
  final Function(int) deleteCategory;
  final BuildContext context;

  _CategoryDataSource(this.categories, this.showCategoryDialog, this.deleteCategory, this.context);

  @override
  DataRow getRow(int index) {
    final category = categories[index];
      return DataRow(cells: [
      DataCell(Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(category.name),
      )),
      DataCell(Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(category.code),
      )),
      DataCell(Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => showCategoryDialog(category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmationDeleteDialog(
                    content: 'Are you sure you want to delete this category?',
                    onConfirm: () {
                      deleteCategory(category.id!);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => categories.length;

  @override
  int get selectedRowCount => 0;
}
