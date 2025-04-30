import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sales_managementv5/model/order_model.dart';
import 'package:sales_managementv5/model/orderitem_model.dart';

class OrderService {
  final String baseUrl = "http://localhost:3000/orders"; // Fixed API URL to match backend

  Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      throw Exception("Error fetching orders: $e");
    }
  }

  Future<void> placeOrder(String customerName, List<OrderItem> items) async {
    try {
      final cartItems = items.map((item) => item.toJson()).toList();
      final response = await http.post(
        Uri.parse(baseUrl),  // Changed from "${baseUrl}/checkout" to "${baseUrl}"
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_name': customerName,
          'cartItems': cartItems,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to place order");
      }
    } catch (e) {
      throw Exception("Error placing order: $e");
    }
  }
}
