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
    _loadData();
  }

  void _loadData() {
    setState(() {
      _ordersFuture = OrderService().getOrders();
      _menusFuture = MenuService.getMenus();
      _categoriesFuture = MenuService.getCategories();
    });
  }

  Widget _buildSummaryCard(String title, int count, IconData icon, List<Color> gradientColors) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black26,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
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
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return _buildEmptyWidget('No orders found.');
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
            leading: const Icon(Icons.shopping_cart, color: Colors.blueAccent),
            title: Text(order.customerName, overflow: TextOverflow.ellipsis),
            subtitle: Text('Total: ₱${order.totalPrice.toStringAsFixed(2)}'),
            trailing: Text(
              order.status,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Placeholder for order details navigation
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuList(List<Menu> menus) {
    if (menus.isEmpty) {
      return _buildEmptyWidget('No menus found.');
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
            leading: const Icon(Icons.restaurant_menu, color: Colors.green),
            title: Text(menu.menuname, overflow: TextOverflow.ellipsis),
            subtitle: Text('Price: ₱${menu.price.toStringAsFixed(2)}'),
            onTap: () {
              // Placeholder for menu details navigation
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return _buildEmptyWidget('No categories found.');
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
            leading: const Icon(Icons.category, color: Colors.orange),
            title: Text(category.name, overflow: TextOverflow.ellipsis),
            onTap: () {
              // Placeholder for category details navigation
            },
          );
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    _loadData();
    await Future.wait([_ordersFuture, _menusFuture, _categoriesFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _refreshData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    return _buildErrorWidget('Failed to load dashboard data: \${snapshot.error}');
                  } else {
                    final orders = snapshot.data![0] as List<Order>;
                    final menus = snapshot.data![1] as List<Menu>;
                    final categories = snapshot.data![2] as List<Category>;

                    // Aggregate orders per day
                    Map<String, int> ordersPerDay = {};
                    for (var order in orders) {
                      String day = order.orderDate.toIso8601String().substring(0, 10);
                      ordersPerDay[day] = (ordersPerDay[day] ?? 0) + 1;
                    }

                    // Sort days ascending
                    var sortedDays = ordersPerDay.keys.toList()..sort();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSummaryCard('Orders', orders.length, Icons.shopping_cart, [Colors.blue.shade700, Colors.blue.shade400]),
                            _buildSummaryCard('Menus', menus.length, Icons.restaurant_menu, [Colors.green.shade700, Colors.green.shade400]),
                            _buildSummaryCard('Categories', categories.length, Icons.category, [Colors.orange.shade700, Colors.orange.shade400]),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Orders Per Day'),
                        SizedBox(
                          height: 200,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: sortedDays.map((day) {
                              int count = ordersPerDay[day]!;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 20,
                                    height: count * 10.0, // scale height
                                    color: Colors.blue.shade400,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(day.substring(5), style: const TextStyle(fontSize: 10)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
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
                    return _buildErrorWidget('Failed to load orders: \${snapshot.error}');
                  } else {
                    final orders = snapshot.data!;
                    return _buildOrderList(orders);
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
                    return _buildErrorWidget('Failed to load menus: \${snapshot.error}');
                  } else {
                    final menus = snapshot.data!;
                    return _buildMenuList(menus);
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
                    return _buildErrorWidget('Failed to load categories: \${snapshot.error}');
                  } else {
                    final categories = snapshot.data!;
                    return _buildCategoryList(categories);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
