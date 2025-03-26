import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sales_managementv5/model/orderitem_model.dart';

class OrderItemService {
  final String baseUrl = "http://localhost:3000/orderItems"; // Update with actual API URL

  // Fetch all items for a specific order
  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final response = await http.get(Uri.parse("$baseUrl/order/$orderId"));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((data) => OrderItem.fromJson(data)).toList();
    } else {
      throw Exception("Failed to load order items");
    }
  }

  // Add an item to an order
  Future<void> createOrderItem(int orderId, int menuId, int quantity, double price) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "order_id": orderId,
        "menu_id": menuId,
        "quantity": quantity,
        "price": price,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create order item");
    }
  }

  // Update an order item
  Future<void> updateOrderItem(int id, int quantity, double price) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "quantity": quantity,
        "price": price,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update order item");
    }
  }

  // Delete an order item
  Future<void> deleteOrderItem(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete order item");
    }
  }
}
