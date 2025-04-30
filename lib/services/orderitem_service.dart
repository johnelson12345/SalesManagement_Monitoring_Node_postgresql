import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sales_managementv5/model/orderitem_model.dart';

class OrderItemService {
  final String baseUrl = "http://localhost:3000/order-items"; // Fixed API URL to match backend

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$orderId"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OrderItem.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load order items");
      }
    } catch (e) {
      throw Exception("Error fetching order items: $e");
    }
  }

  Future<void> addOrderItem(OrderItem item) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add order item");
      }
    } catch (e) {
      throw Exception("Error adding order item: $e");
    }
  }

  Future<void> removeOrderItem(int itemId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$itemId"));
      if (response.statusCode != 200) {
        throw Exception("Failed to remove order item");
      }
    } catch (e) {
      throw Exception("Error removing order item: $e");
    }
  }
}
