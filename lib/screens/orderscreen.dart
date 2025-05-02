import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/order_model.dart';
import 'package:sales_managementv5/model/orderitem_model.dart';
import '../services/order_service.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _orders;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all'; // New status filter state

  Map<int, String> _orderStatusMap = {};

  static const int pageSize = 20;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _orders = _orderService.getOrders();
      _orders.then((orders) {
        setState(() {
          _orderStatusMap = { for (var order in orders) order.id ?? 0 : order.status };
          _currentPage = 0; // Reset to first page on refresh
        });
      });
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  List<Order> _filterOrders(List<Order> orders) {
    List<Order> filtered = orders;

    // Filter by status if not 'all'
    if (_statusFilter != 'all') {
      filtered = filtered.where((order) => order.status == _statusFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.items.any((item) => item.menuName.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    return filtered;
  }

  List<Order> _getCurrentPageOrders(List<Order> orders) {
    int start = _currentPage * pageSize;
    int end = start + pageSize;
    if (start >= orders.length) return [];
    if (end > orders.length) end = orders.length;
    return orders.sublist(start, end);
  }

  void _goToNextPage(List<Order> orders) {
    if ((_currentPage + 1) * pageSize < orders.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Management"),
        elevation: 0,
        flexibleSpace: Container(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Combined smaller card for filter and search
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Status filter dropdown smaller width
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _statusFilter = value;
                              _currentPage = 0; // Reset page on filter change
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Expanded search filter
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search orders...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _currentPage = 0; // Reset page on search clear
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _currentPage = 0; // Reset page on search change
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Order>>(
                future: _orders,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            "Failed to load orders",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: _refreshOrders,
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  final orders = snapshot.data ?? [];
                  final filteredOrders = _filterOrders(orders);
                  final currentPageOrders = _getCurrentPageOrders(filteredOrders);

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? "No orders available"
                                : "No orders matching your search",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _currentPage = 0;
                                });
                              },
                              child: const Text("Clear search"),
                            ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _refreshOrders();
                          },
                          color: Colors.blue,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: currentPageOrders.length,
                            itemBuilder: (context, index) {
                              final order = currentPageOrders[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ExpansionTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          ((_currentPage * pageSize) + index + 1).toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      order.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(order.orderDate),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              const TextSpan(text: "Total: "),
                                              TextSpan(
                                                text: "₱${order.totalPrice.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.blue.shade600,
                                    ),
                                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(height: 1),
                                      if (order.items.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          child: Text(
                                            "No items in this order",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        )
                                      else ...[
                                        const Padding(
                                          padding: EdgeInsets.only(top: 12, bottom: 8),
                                          child: Text(
                                            "Order Items:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        ...order.items.map(
                                          (item) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.menuName,
                                                    style: const TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    "Qty: ${item.quantity}",
                                                    style: TextStyle(
                                                      color: Colors.blue.shade800,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Add dropdown for order status
                                        Row(
                                          children: [
                                            const Text(
                                              "Status: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            DropdownButton<String>(
                                              value: _orderStatusMap[order.id] ?? 'pending',
                                              items: [
                                                DropdownMenuItem(
                                                  value: 'pending',
                                                  child: Text(
                                                    'Pending',
                                                    style: TextStyle(color: Colors.orange.shade700),
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'completed',
                                                  child: Text(
                                                    'Completed',
                                                    style: TextStyle(color: Colors.green.shade700),
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'cancelled',
                                                  child: Text(
                                                    'Cancelled',
                                                    style: TextStyle(color: Colors.red.shade700),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (String? newValue) async {
                                                if (newValue != null) {
                                                  bool success = await _orderService.updateOrderStatus(order.id!, newValue);
                                                  if (success) {
                                                    setState(() {
                                                      _orderStatusMap[order.id!] = newValue;
                                                    });
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Order status updated to \$newValue')),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Failed to update order status')),
                                                    );
                                                  }
                                                }
                                              },
                                              style: TextStyle(
                                                color: _orderStatusMap[order.id] == 'completed'
                                                    ? Colors.green.shade700
                                                    : _orderStatusMap[order.id] == 'cancelled'
                                                        ? Colors.red.shade700
                                                        : Colors.orange.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Pagination controls
                      if (filteredOrders.length > pageSize)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _currentPage > 0 ? () => _goToPreviousPage() : null,
                                child: const Text('Previous'),
                              ),
                              const SizedBox(width: 16),
                              Text('Page ${_currentPage + 1} of ${((filteredOrders.length - 1) / pageSize + 1).toInt()}'),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: (_currentPage + 1) * pageSize < filteredOrders.length
                                    ? () => _goToNextPage(filteredOrders)
                                    : null,
                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshOrders,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
