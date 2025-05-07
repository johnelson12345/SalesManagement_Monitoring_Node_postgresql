import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/category_model.dart';
import 'package:sales_managementv5/model/menu_model.dart';
import 'package:sales_managementv5/services/menu_service.dart';
import 'package:sales_managementv5/admin_screen/menu_dialog.dart';
import 'package:sales_managementv5/widgets/confirmation_delete_dialog.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Menu> _menus = [];
  List<Menu> _filteredMenus = [];
  List<Category> _categories = [];
  final TextEditingController _searchController = TextEditingController();

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
          _categories = categories;
        });
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  void _filterMenus() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMenus = _menus.where((menu) {
        return (menu.menuname.toLowerCase().contains(query)) ||
            (menu.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

 void _showMenuDialog(Menu? menu) {
  showDialog(
    context: context,
    builder: (context) {
      return MenuDialog(
        menu: menu,
        categories: _categories,
        onSave: (Menu updatedMenu) async {
          if (menu == null) {
            await MenuService.addMenu(updatedMenu);
          } else {
            await MenuService.updateMenu(menu.id!, updatedMenu);
          }
          _loadMenus();
        },
      );
    },
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
        title: const Text(
          "Menus",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search menus...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white, size: 38),
                  label: const Text("Add Menu", style: TextStyle(color: Colors.white)),
                  onPressed: () => _showMenuDialog(null),
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
              child: _filteredMenus.isEmpty
                  ? const Center(child: Text("No menus available"))
                  : Container(
                      width: double.infinity,
                      child: PaginatedDataTable(
                        header: const Text("Menus", style: TextStyle(fontSize: 20)),
                        rowsPerPage: 5,
                        // Removed columnSpacing to match category screen style
                        columns: const [
                          DataColumn(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Menu Name", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Category Name", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          DataColumn(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                        source: _MenuDataSource(
                          _filteredMenus,
                          _categories,
                          _showMenuDialog,
                          _deleteMenu,
                          context
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

class _MenuDataSource extends DataTableSource {
  final List<Menu> menus;
  final List<Category> categories;
  final Function(Menu?) showMenuDialog;
  final Function(int) deleteMenu;
  final BuildContext context;

  _MenuDataSource(this.menus, this.categories, this.showMenuDialog, this.deleteMenu, this.context);

  @override
  DataRow getRow(int index) {
    final menu = menus[index];
    final categoryName = categories.firstWhere(
      (category) => category.id == menu.categoryid,
      orElse: () => Category(id: 0, name: "Unknown", code: ''),
    ).name;

    return DataRow(cells: [
      DataCell(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(menu.menuname),
      )),
      DataCell(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(categoryName),
      )),
      DataCell(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(menu.price.toString()),
      )),
      DataCell(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(menu.status),
      )),
      DataCell(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => showMenuDialog(menu),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmationDeleteDialog(
                    content: 'Are you sure you want to delete this menu?',
                    onConfirm: () {
                      deleteMenu(menu.id!);
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
  int get rowCount => menus.length;

  @override
  int get selectedRowCount => 0;
}