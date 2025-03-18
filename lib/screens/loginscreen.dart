import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sales_managementv5/screens/categoryscreen.dart';
import 'package:sales_managementv5/screens/mainscreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // To store JWT token

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    const String apiUrl = "http://localhost:3000/users/login"; // Change to your API URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = data['token'];

        // Store JWT token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Navigate to CategoryScreen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout(child: CategoryScreen(),)),
        );
      } else {
        setState(() {
          errorMessage = data['error'] ?? "Invalid email or password";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: Unable to connect to server";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    child: const Text("Login"),
                  ),
            const SizedBox(height: 10),
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
