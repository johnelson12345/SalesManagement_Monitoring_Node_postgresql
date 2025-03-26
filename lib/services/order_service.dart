import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sales_managementv5/model/order_model.dart';

class OrderService {
  final String baseUrl = "http://localhost:3000/orders"; // Update with actual API URL

  // Fetch all orders
  Future<List<Order>> getOrders() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((data) => Order.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load orders");
    }
  }

  // Create a new order
  Future<void> createOrder(String customerName, double totalPrice) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "customer_name": customerName,
        "total_price": totalPrice,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create order");
    }
  }

  // Delete an order
  Future<void> deleteOrder(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete order");
    }
  }
}
