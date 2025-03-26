import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/order_model.dart';
import '../services/order_service.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _orders;
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _orders = _orderService.getOrders();
  }

  void _addOrder() async {
    String customerName = _customerController.text;
    double totalPrice = double.tryParse(_totalPriceController.text) ?? 0.0;

    if (customerName.isNotEmpty && totalPrice > 0) {
      await _orderService.createOrder(customerName, totalPrice);
      setState(() {
        _orders = _orderService.getOrders();
      });
      _customerController.clear();
      _totalPriceController.clear();
    }
  }

  void _deleteOrder(int id) async {
    await _orderService.deleteOrder(id);
    setState(() {
      _orders = _orderService.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _customerController,
                  decoration: InputDecoration(labelText: "Customer Name"),
                ),
                TextField(
                  controller: _totalPriceController,
                  decoration: InputDecoration(labelText: "Total Price"),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: _addOrder,
                  child: Text("Add Order"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _orders,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading orders"));
                }

                final orders = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(orders[index].customerName),
                      subtitle: Text("\$${orders[index].totalPrice}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOrder(orders[index].id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
