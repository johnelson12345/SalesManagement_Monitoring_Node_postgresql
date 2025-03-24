import 'package:flutter/material.dart';

class OrdersBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const OrdersBottomSheet({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    double totalPrice = orders.fold(0, (sum, item) => sum + (item["price"] * item["quantity"]));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Orders Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Colors.grey),
                children: [
                  Padding(padding: EdgeInsets.all(8.0), child: Text("Menu", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8.0), child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.all(8.0), child: Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              ...orders.map((item) => TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item["menu"])),
                  Padding(padding: const EdgeInsets.all(8.0), child: Text("\$${item["price"]}")),
                  Padding(padding: const EdgeInsets.all(8.0), child: Text("${item["quantity"]}")),
                ],
              )),
            ],
          ),
          const SizedBox(height: 10),
          Text("Total Price: \$${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
