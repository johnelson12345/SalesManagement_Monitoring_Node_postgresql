import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/menu_model.dart';

class CartDialog extends StatelessWidget {
  final List<Menu> cartItems;
  final Map<int, int> cartQuantities; // To track item quantities

  const CartDialog({
    super.key,
    required this.cartItems,
    required this.cartQuantities,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Cart",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: cartItems.isEmpty
              ? [const Text("Your cart is empty.")]
              : cartItems.map((menu) {
                  int quantity = cartQuantities[menu.id] ?? 0;
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      
                      title: Text(
                        menu.menuname,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("₱${menu.price.toStringAsFixed(2)}"),
                      trailing: Text("x$quantity"),
                    ),
                  );
                }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
      ],
    );
  }

  // Function to build image
  Widget _buildImage(String imageUrl) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey[200],
      ),
      child: Image.network(imageUrl, fit: BoxFit.cover),
    );
  }
}
