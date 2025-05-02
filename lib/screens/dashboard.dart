import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/order_model.dart';
import 'package:sales_managementv5/model/menu_model.dart';
import 'package:sales_managementv5/model/category_model.dart';
import '../services/order_service.dart';
import '../services/menu_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Order>> _ordersFuture;
  late Future<List<Menu>> _menusFuture;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = OrderService().getOrders();
    _menusFuture = MenuService.getMenus();
    _categoriesFuture = MenuService.getCategories();
  }

  Widget _buildSummaryCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 150,
        // height: 120,  // Removed fixed height to prevent overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,  // Added to shrink-wrap content vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<dynamic>>(
              future: Future.wait([_ordersFuture, _menusFuture, _categoriesFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load dashboard data: \${snapshot.error}'));
                } else {
                  final orders = snapshot.data![0] as List<Order>;
                  final menus = snapshot.data![1] as List<Menu>;
                  final categories = snapshot.data![2] as List<Category>;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryCard('Orders', orders.length, Icons.shopping_cart, Colors.blue),
                      _buildSummaryCard('Menus', menus.length, Icons.restaurant_menu, Colors.green),
                      _buildSummaryCard('Categories', categories.length, Icons.category, Colors.orange),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Orders'),
            FutureBuilder<List<Order>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load orders: \${snapshot.error}'));
                } else {
                  final orders = snapshot.data!;
                  if (orders.isEmpty) {
                    return const Text('No orders found.');
                  }
                  final recentOrders = orders.take(5).toList();
                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentOrders.length,
                      itemBuilder: (context, index) {
                        final order = recentOrders[index];
                        return ListTile(
                          title: Text(order.customerName),
                          subtitle: Text('Total: ₱${order.totalPrice.toStringAsFixed(2)}'),
                          trailing: Text(order.status, style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {
                            // Placeholder for order details navigation
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Menus'),
            FutureBuilder<List<Menu>>(
              future: _menusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load menus: \${snapshot.error}'));
                } else {
                  final menus = snapshot.data!;
                  if (menus.isEmpty) {
                    return const Text('No menus found.');
                  }
                  final recentMenus = menus.take(5).toList();
                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentMenus.length,
                      itemBuilder: (context, index) {
                        final menu = recentMenus[index];
                        return ListTile(
                          title: Text(menu.menuname),
                          subtitle: Text('Price: ₱${menu.price.toStringAsFixed(2)}'),
                          onTap: () {
                            // Placeholder for menu details navigation
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Categories'),
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load categories: \${snapshot.error}'));
                } else {
                  final categories = snapshot.data!;
                  if (categories.isEmpty) {
                    return const Text('No categories found.');
                  }
                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          title: Text(category.name),
                          onTap: () {
                            // Placeholder for category details navigation
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
