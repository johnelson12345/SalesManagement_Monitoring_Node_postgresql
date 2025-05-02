import 'package:flutter/material.dart';
import 'package:sales_managementv5/screens/categoryscreen.dart';
import 'package:sales_managementv5/screens/loginscreen.dart';
import 'package:sales_managementv5/screens/mainscreen.dart';
import 'package:sales_managementv5/screens/menus_screen.dart';

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
