import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sales_managementv5/model/category_model.dart';
import 'package:sales_managementv5/model/menu_model.dart';

class MenuService {
  static const String _baseUrl = "http://localhost:3000/menus"; // Replace with your actual API URL
  static const String _categoriesUrl = "http://localhost:3000/categories"; // Add Categories API URL
  // Fetch menus from the API
  static Future<List<Menu>> getMenus() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((menu) => Menu.fromJson(menu)).toList();
    } else {
      throw Exception('Failed to load menus');
    }
  }

  // Add a new menu item
static Future<void> addMenu(Menu menu) async {
  
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(menu.toJson()),
    );

}


  // Update an existing menu item
  static Future<void> updateMenu(int id, Menu menu) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(menu.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update menu');
    }
  }

  // Delete a menu item
  static Future<void> deleteMenu(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete menu');
    }
  }
    // Fetch categories from the API
  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse(_categoriesUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
