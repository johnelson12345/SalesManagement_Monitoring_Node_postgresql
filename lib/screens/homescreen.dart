import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sales_managementv5/services/category_service.dart';
import 'package:sales_managementv5/services/menu_service.dart';
import 'package:sales_managementv5/model/category_model.dart';
import 'package:sales_managementv5/model/menu_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  Map<int, List<Menu>> categoryMenus = {};
  bool isLoading = true;
 int cartItemCount = 0;

   void incrementCart() {
    setState(() {
      cartItemCount++; // 🔹 Increase cart count when Buy button is clicked
    });
  }
  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndMenus();
  }

  Future<void> _fetchCategoriesAndMenus() async {
  try {
    List<Category> fetchedCategories = await CategoryService.getCategories();
    List<Menu> allMenus = await MenuService.getMenus();
    Map<int, List<Menu>> fetchedMenus = {};

    for (var category in fetchedCategories) {
      fetchedMenus[category.id!] =
          allMenus.where((menu) => menu.categoryid == category.id).toList();
    }

    setState(() {
      categories = fetchedCategories;
      categoryMenus = fetchedMenus;
      isLoading = false;
    });
  } catch (e) {
    print("Error fetching data: $e");
    setState(() => isLoading = false);
  }
}


 @override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: categories.isNotEmpty ? categories.length : 1,
    child: Scaffold(
      appBar: AppBar(
        title: const Text("Menus"),
        bottom: categories.isNotEmpty
            ? TabBar(
                isScrollable: categories.length > 4 ? true : false,
                labelColor: Colors.white, // Active tab text color
                unselectedLabelColor: Colors.grey.shade400, // Inactive tab text color
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), // Rounded indicator
                  color: Colors.orange.shade600, // Active tab background color
                ),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                indicatorSize: TabBarIndicatorSize.label, // Indicator fits label
                tabs: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Tab(text: category.name),
                  );
                }).toList(),
              )
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isNotEmpty
              ? TabBarView(
                  children: categories.map((category) {
                    return _buildCategoryMenu(category.id!);
                  }).toList(),
                )
              : const Center(child: Text("No Menus Available")),

      // 🛒 Floating Action Button (FAB) with Cart Badge
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cart clicked!")),
              );
            },
            backgroundColor: Colors.orange.shade600,
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
          if (cartItemCount > 0) // Show badge only if cart has items
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '$cartItemCount',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}


  Widget _buildCategoryMenu(int categoryId) {
    List<Menu> menus = categoryMenus[categoryId] ?? [];

    return menus.isNotEmpty
        ? GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Adjust the number of cards per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              return MenuCard(menu: menus[index], incrementCart: incrementCart,);
            },
          )
        : const Center(child: Text("No items in this category"));
  }
}

class MenuCard extends StatelessWidget {
  final Menu menu;
  final VoidCallback incrementCart; 

  const MenuCard({super.key, required this.menu,required this.incrementCart,  });

  @override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double cardWidth = screenWidth * 0.23; // Slightly bigger for better visibility

  return Scaffold(
    body: Center(
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🖼️ Image
                Container(
                  width: cardWidth * 0.8,
                  height: cardWidth * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: _buildImage(menu.image),
                ),
                const SizedBox(height: 8),

                // 🏷️ Name
                Text(
                  menu.menuname,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // 💰 Price
                Text(
                  "₱${menu.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // 🛒 Buy Button
                SizedBox(
                  width: cardWidth * 0.8,
                  child: ElevatedButton.icon(
                    onPressed: incrementCart,
                    icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 16),
                    label: const Text("Buy", style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


 Widget _buildImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey, size: 40);
    }

    try {
      Uint8List bytes = base64Decode(base64String);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
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
