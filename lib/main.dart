import 'package:flutter/material.dart';
import 'package:sales_managementv5/screens/categoryscreen.dart';
import 'package:sales_managementv5/screens/mainscreen.dart';

void main() {
  runApp(MyApp());
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
      home: const MainLayout(child: CategoryScreen()), // Wrap CategoryScreen inside MainLayout
    );
  }
}
