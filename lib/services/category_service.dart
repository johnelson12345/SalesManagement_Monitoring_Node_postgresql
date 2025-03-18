import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sales_managementv5/model/category_model.dart';

class CategoryService {
  static const String baseUrl = "http://localhost:3000/categories"; // Change to your server's URL if deployed

  // **Create a new category**
  static Future<bool> addCategory(Category category) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(category.toJson()),
    );

    return response.statusCode == 201;
  }

  // **Read all categories**
  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  // **Update a category**
  static Future<bool> updateCategory(int id, Category category) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(category.toJson()),
    );

    return response.statusCode == 200;
  }

  // **Delete a category**
  static Future<bool> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    return response.statusCode == 200;
  }
}
