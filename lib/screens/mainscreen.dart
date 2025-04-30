import 'package:flutter/material.dart';
import 'package:sales_managementv5/screens/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_managementv5/screens/categoryscreen.dart';
import 'package:sales_managementv5/screens/menus_screen.dart';
import 'package:sales_managementv5/screens/userscreen.dart';
import 'package:sales_managementv5/screens/loginscreen.dart';
import 'package:sales_managementv5/screens/orderscreen.dart';  // Added import for OrderScreen

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String userName = "Guest";
  String userEmail = "guest@example.com";

@override
void initState() {
  super.initState();
  _loadUserDetails();
}

Future<void> _loadUserDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    userName = prefs.getString('userName') ?? "Guest";
    userEmail = prefs.getString('userEmail') ?? "guest@example.com";
  });
}


  @override
  Widget build(BuildContext context) {
    bool isLoginScreen = widget.child is LoginScreen;
    Color primaryColor = const Color(0xFF203A43);
    Color secondaryColor = const Color(0xFF0F2027);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sales Management",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      drawer: isLoginScreen ? null : _buildDrawer(primaryColor, secondaryColor),
      body: widget.child,
    );
  }

  Widget _buildDrawer(Color primaryColor, Color secondaryColor) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userEmail,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blueGrey),
            ),
          ),
          _buildDrawerItem(Icons.category, "Home", primaryColor, () {
            _navigateToScreen(context,  HomeScreen());
          }),
          _buildDrawerItem(Icons.category, "Categories", primaryColor, () {
            _navigateToScreen(context, const CategoryScreen());
          }),
          _buildDrawerItem(Icons.restaurant_menu, "Menus", primaryColor, () {
            _navigateToScreen(context, const MenuScreen());
          }),
          _buildDrawerItem(Icons.people, "Accounts", primaryColor, () {
            _navigateToScreen(context, const UserListScreen());
          }),
          _buildDrawerItem(Icons.list_alt, "Orders", primaryColor, () {  // Added Orders drawer item
            _navigateToScreen(context, const OrderScreen());
          }),
          const Divider(),
          _buildDrawerItem(Icons.logout, "Logout", Colors.red, _showLogoutDialog),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainLayout(child: screen)),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
