import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_managementv5/model/category_model.dart';
import 'package:sales_managementv5/model/menu_model.dart';  // Assuming you have a Menu model
import 'package:sales_managementv5/services/menu_service.dart';  // Assuming you have a MenuService to handle CRUD operations

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Menu> _menus = [];
  List<Menu> _filteredMenus = [];
  List<Category> _categories = [];

// Store only category names
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();  // Category related field
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  File? _selectedImage; // Store selected image
String? _selectedCategoryId;
  @override
  void initState() {
    super.initState();
    _loadMenus();
    _loadCategories();
    _searchController.addListener(_filterMenus);
  }

  void _loadMenus() async {
   
      final menus = await MenuService.getMenus();
      if (mounted) {
        setState(() {
          _menus = menus;
          _filteredMenus = menus;
        });
      }
   
  }
void _loadCategories() async {
  try {
    final categories = await MenuService.getCategories();
    if (mounted) {
      setState(() {
        _categories = categories; // Assign directly
      });
    }
  } catch (e) {
    print("Error loading categories: $e");
  }
}




 void _filterMenus() {
  String query = _searchController.text.toLowerCase();
  setState(() {
    _filteredMenus = _menus
        .where((menu) =>
            (menu.menuname.toLowerCase().contains(query) ) ||
            (menu.description?.toLowerCase().contains(query) ?? false))
        .toList();
  });
}
Future<void> _pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() {
      _selectedImage = File(pickedFile.path.replaceAll('\\', '/')); // Fix path format
    });
  }
}



  void _showMenuDialog({Menu? menu}) {
    if (menu != null) {
      _nameController.text = menu.menuname;
      _categoryController.text = menu.categoryid.toString(); // Assuming categoryid is the ID to show
      _descriptionController.text = menu.description ?? '';
      _priceController.text = menu.price.toString();
      _statusController.text = menu.status;
    } else {
      _nameController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _statusController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(menu == null ? "Add Menu" : "Edit Menu"),
          content: Column(
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
                items: _categories.map((category) {
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
              ),
              const SizedBox(height: 12),
             DropdownButtonFormField<String>(
                      value: _statusController.text.isNotEmpty ? _statusController.text : "available", 
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                      items: ["available", "soldout"].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _statusController.text = value!;
                      },
                    ),
                    const SizedBox(height: 12),

                              Column(
                  children: [
                    _selectedImage != null
                        ? Image.file(_selectedImage!, height: 100) // Display selected image
                        : const Text("No image selected"),
                    
                     ElevatedButton.icon(
                    onPressed: () async {
                      await _pickImage();
                      setState(() {}); // Now updates UI inside the dialog
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("Choose Image"),
                  ),
                  ],
                )

            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                   
                    _priceController.text.isEmpty ||
                    _statusController.text.isEmpty) return;

                if (menu == null) {
                  await MenuService.addMenu(
                    Menu(
                      menuname: _nameController.text,
                      categoryid: int.tryParse(_selectedCategoryId ?? '') ?? 0,
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                      status: _statusController.text,
                    ),
                  );
                } else {
                  await MenuService.updateMenu(
                    menu.id!,
                    Menu(
                      menuname: _nameController.text,
                      categoryid: int.tryParse(_selectedCategoryId ?? '') ?? 0, 
                      description: _descriptionController.text,
                      price: double.parse(_priceController.text),
                      status: _statusController.text,
                    ),
                  );
                }
                _loadMenus();
                Navigator.pop(context);
              },
              child: Text(menu == null ? "Add" : "Update"),
            ),
          ],
        );
      },
        );
      }
    );
  }
  

  void _deleteMenu(int id) async {
    await MenuService.deleteMenu(id);
    _loadMenus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menus", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Menu"),
              onPressed: () => _showMenuDialog(),
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
                hintText: "Search menus...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredMenus.isEmpty
                  ? const Center(child: Text("No menus available"))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Horizontal scrolling
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, 
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.blueGrey), // Set header color
                          columnSpacing: 200,
                          border: TableBorder.all(width: 1, color: Colors.grey),
                          columns: const [
                            DataColumn(label: Text("Menu Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text("Category Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text("Price", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                            DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          ],
                          rows: _filteredMenus.map((menu) {
                            return DataRow(cells: [
                              DataCell(Text(menu.menuname)),
                              DataCell(Text(
                                _categories.firstWhere(
                                  (category) => category.id == menu.categoryid,
                                  orElse: () => Category(id: 0, name: "Unknown", code: ''),
                                ).name,
                                )),

                              DataCell(Text(menu.price.toString())),
                              DataCell(Text(menu.status)),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showMenuDialog(menu: menu),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteMenu(menu.id!),
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
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
