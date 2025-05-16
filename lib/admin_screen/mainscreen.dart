import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_managementv5/admin_screen/dashboard.dart';
import 'package:sales_managementv5/admin_screen/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_managementv5/admin_screen/categoryscreen.dart';
import 'package:sales_managementv5/admin_screen/menus_screen.dart';
import 'package:sales_managementv5/admin_screen/userscreen.dart';
import 'package:sales_managementv5/admin_screen/loginscreen.dart';
import 'package:sales_managementv5/admin_screen/orderscreen.dart';  // Added import for OrderScreen
import 'package:sales_managementv5/admin_screen/custom_search_delegate.dart';
import 'package:sales_managementv5/model/notification_model.dart' as notif;
import 'notification_dialog.dart';
import 'package:sales_managementv5/services/notification_service.dart';


class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String userName = "Guest";
  String userEmail = "guest@example.com";

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _notificationService.addListener(_notificationListener);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_notificationListener);
    super.dispose();
  }

  void _notificationListener() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Guest";
      userEmail = prefs.getString('userEmail') ?? "guest@example.com";
      userRole = prefs.getString('userRole') ?? "guest";
    });
  }

  String userRole = "guest";

  Widget _buildDrawer(Color primaryColor, Color secondaryColor) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
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
          Expanded(
            child: ListView(
              children: [
                if (userRole == "admin") ...[
                  _buildDrawerItem(Icons.dashboard, "Dashboard", primaryColor, () {
                    _navigateToScreen(context, const DashboardScreen());
                  }),
                  _buildDrawerItem(Icons.home, "Home", primaryColor, () {
                    _navigateToScreen(context, HomeScreen(
                      onOrderPlaced: () {
                        _notificationService.addNotification("Order Placed", "Your order has been placed successfully.");
                      },
                    ));
                  }),
                  _buildDrawerItem(Icons.category, "Categories", primaryColor, () {
                    _navigateToScreen(context, const CategoryScreen());
                  }),
                  _buildDrawerItem(Icons.restaurant_menu, "Menus", primaryColor, () {
                    _navigateToScreen(context, const MenuScreen());
                  }),
                  _buildDrawerItem(Icons.list_alt, "Orders", primaryColor, () {
                    _navigateToScreen(context, const OrderScreen());
                  }),
                  _buildDrawerItem(Icons.people, "Accounts", primaryColor, () {
                    _navigateToScreen(context, const UserListScreen());
                  }),
                ] else if (userRole == "kitchen") ...[
                  _buildDrawerItem(Icons.restaurant_menu, "Menus", primaryColor, () {
                    _navigateToScreen(context, const MenuScreen());
                  }),
                  _buildDrawerItem(Icons.list_alt, "Orders", primaryColor, () {
                    _navigateToScreen(context, const OrderScreen());
                  }),
                ] else if (userRole == "cashier") ...[
                  _buildDrawerItem(Icons.list_alt, "Orders", primaryColor, () {
                    _navigateToScreen(context, const OrderScreen());
                  }),
                  _buildDrawerItem(Icons.people, "Accounts", primaryColor, () {
                    _navigateToScreen(context, const UserListScreen());
                  }),
                ],
                const Divider(),
                _buildDrawerItem(Icons.logout, "Logout", Colors.red, _showLogoutDialog),
              ],
            ),
          ),
          // Version information added here
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'v1.0.0', // Replace with your actual version
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '© ${DateTime.now().year} Mae B. Honorario and Team', 
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Built: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool isLoginScreen = widget.child is LoginScreen;
    Color primaryColor = const Color(0xFF203A43);
    Color secondaryColor = const Color(0xFF0F2027);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Dine'84 Sales Management & Monitoring",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          ),
          Stack(
            children: [

          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => NotificationDialog(notifications: _notificationService.notifications),
              );
            },
          ),
              Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '${_notificationService.notificationCount}', // Dynamic badge count
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blueGrey),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                // TODO: Navigate to profile screen
              } else if (value == 'settings') {
                // TODO: Navigate to settings screen
              } else if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      drawer: (isLoginScreen || userRole == "cashier") ? null : _buildRoleBasedDrawer(primaryColor, secondaryColor),
      body: widget.child,
    );
  }

  Widget _buildRoleBasedDrawer(Color primaryColor, Color secondaryColor) {
  return Drawer(
    child: Column(
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: primaryColor),
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
        Expanded(
          child: ListView(
            children: [
              if (userRole == "admin") ...[
                _buildDrawerItem(Icons.dashboard, "Dashboard", primaryColor, () {
                  _navigateToScreen(context, const DashboardScreen());
                }),
                _buildDrawerItem(Icons.home, "Home", primaryColor, () {
                  _navigateToScreen(context, HomeScreen(
                    onOrderPlaced: () {
                      _notificationService.addNotification("Order Placed", "Your order has been placed successfully.");
                    },
                  ));
                }),
                _buildDrawerItem(Icons.category, "Categories", primaryColor, () {
                  _navigateToScreen(context, const CategoryScreen());
                }),
                _buildDrawerItem(Icons.restaurant_menu, "Menus", primaryColor, () {
                  _navigateToScreen(context, const MenuScreen());
                }),
                _buildDrawerItem(Icons.list_alt, "Orders", primaryColor, () {
                  _navigateToScreen(context, const OrderScreen());
                }),
                _buildDrawerItem(Icons.people, "Accounts", primaryColor, () {
                  _navigateToScreen(context, const UserListScreen());
                }),
              ] else if (userRole == "kitchen") ...[
                 _buildDrawerItem(Icons.category, "Categories", primaryColor, () {
                  _navigateToScreen(context, const CategoryScreen());
                }),
                _buildDrawerItem(Icons.restaurant_menu, "Menus", primaryColor, () {
                  _navigateToScreen(context, const MenuScreen());
                }),
                _buildDrawerItem(Icons.list_alt, "Orders", primaryColor, () {
                  _navigateToScreen(context, const OrderScreen());
                }),
              ] else if (userRole == "cashier") ...[
                _buildDrawerItem(Icons.home, "Home", primaryColor, () {
                  _navigateToScreen(context, HomeScreen());
                }),
              ],
              const Divider(),
              _buildDrawerItem(Icons.logout, "Logout", Colors.red, _showLogoutDialog),
            ],
          ),
        ),
        // Version information added here
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'v1.0.0', // Replace with your actual version
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '© ${DateTime.now().year} Mae B. Honorario and Team', 
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Built: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
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
    if (userRole == "cashier" && screen.runtimeType == DashboardScreen) {
      screen = HomeScreen();
    }
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
