import 'package:flutter/material.dart';
import 'package:sales_managementv5/screens/categoryscreen.dart';
import 'package:sales_managementv5/screens/menus_screen.dart';
import 'package:sales_managementv5/screens/userscreen.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Management"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 40, color: Colors.white),
                  SizedBox(height: 10),
                  Text("Admin Panel", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.category, "Categories", () {
              _navigateToScreen(context, const CategoryScreen());
            }),
            _buildDrawerItem(Icons.dashboard, "Menus", () {
              _navigateToScreen(context, MenuScreen());
            }),
             _buildDrawerItem(Icons.dashboard, "Accounts", () {
              _navigateToScreen(context, UserListScreen());
            }),
            _buildDrawerItem(Icons.shopping_cart, "Products", () {
              // Navigate to Products Screen (Replace with actual screen)
            }),
            _buildDrawerItem(Icons.logout, "Logout", () {
              // Add logout functionality
            }),
          ],
        ),
      ),
      body: widget.child,
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainLayout(child: screen)),
    );
  }
}
