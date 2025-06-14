import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/orderitem_model.dart';

class ReceiptDialog extends StatelessWidget {
  final String customerName;
  final String tableNumber;
  final List<OrderItem> orders;
  final double totalPrice;

  const ReceiptDialog({
    Key? key,
    required this.customerName,
    required this.tableNumber,
    required this.orders,
    required this.totalPrice,
  }) : super(key: key);

  void _printReceipt() {
    // Placeholder for print functionality
    // User can integrate actual printing logic here
    print("Printing receipt for customer: \$customerName");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Receipt',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text('Customer Name: $customerName',
                  style: const TextStyle(fontSize: 16)),
              Text('Table Number: $tableNumber',
                  style: const TextStyle(fontSize: 16)),
              const Divider(height: 20, thickness: 2),
              const Text('Orders:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...orders.map((order) {
                double itemTotal = order.price * order.quantity;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${order.menuName} x${order.quantity}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        '₱${itemTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(height: 20, thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('₱${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _printReceipt();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Print functionality is not implemented yet.')),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
