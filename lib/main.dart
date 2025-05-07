import 'package:flutter/material.dart';
import 'package:sales_managementv5/admin_screen/categoryscreen.dart';
import 'package:sales_managementv5/admin_screen/loginscreen.dart';
import 'package:sales_managementv5/admin_screen/mainscreen.dart';
import 'package:sales_managementv5/admin_screen/menus_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sales Management and Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const  LoginScreen());
  
  }
}
