import 'package:flutter/material.dart';
import 'package:sales_managementv5/admin_screen/receipt_dialog.dart';
import 'package:sales_managementv5/model/menu_model.dart';
import 'package:sales_managementv5/model/orderitem_model.dart';
import 'package:sales_managementv5/services/order_service.dart';
import 'package:sales_managementv5/widgets/image_helper.dart';

void showCartDialog(BuildContext context, List<Menu> cartItems, Map<int, int> cartQuantities, {VoidCallback? onOrderPlaced}) {
  TextEditingController customerNameController = TextEditingController();
  TextEditingController tableNumberController = TextEditingController();
  final OrderService orderService = OrderService();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          double totalPrice = cartItems.fold(
            0,
            (sum, item) => sum + (item.price * (cartQuantities[item.id] ?? 1)),
          );

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Customer Name Input Field
                    TextField(
                      controller: customerNameController,
                      decoration: InputDecoration(
                        labelText: "Customer Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Table Number Input Field
                    TextField(
                      controller: tableNumberController,
                      decoration: InputDecoration(
                        labelText: "Table Number",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.table_chart),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Orders MENUs Cart",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    
                    cartItems.isNotEmpty
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: SingleChildScrollView(
                              child: Column(
                                children: cartItems.map((menu) {
                                  int quantity = (cartQuantities[menu.id] ?? 1).toInt();
                                  double itemTotal = menu.price * quantity;

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          ImageHelper.buildImage(menu.image, width: 50, height: 50),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(menu.menuname,
                                                    style: const TextStyle(
                                                        fontSize: 14, fontWeight: FontWeight.w500)),
                                                Text(
                                                  "₱${menu.price.toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove_circle_outline,
                                                    color: Colors.redAccent, size: 20),
                                                onPressed: () {
                                                  if (quantity > 1) {
                                                    setState(() {
                                                      cartQuantities[menu.id!] =
                                                          (cartQuantities[menu.id!] ?? 1) - 1;
                                                    });
                                                  }
                                                },
                                              ),
                                              Text("$quantity",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold)),
                                              IconButton(
                                                icon: const Icon(Icons.add_circle_outline,
                                                    color: Colors.green, size: 20),
                                                onPressed: () {
                                                  setState(() {
                                                    cartQuantities[menu.id!] =
                                                        (cartQuantities[menu.id!] ?? 1) + 1;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              "₱${itemTotal.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                                            onPressed: () {
                                              setState(() {
                                                cartItems.remove(menu);
                                                cartQuantities.remove(menu.id);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "Your cart is empty",
                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                          ),

                    const Divider(),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            "₱${totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Close Button
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Close",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),

                        // Checkout Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            String customerName = customerNameController.text.trim();
                            String tableNumber = tableNumberController.text.trim();
                            if (customerName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please enter a customer name")),
                              );
                              return;
                            }

                            try {
                              final orderItems = cartItems.map((menu) {
                                int quantity = cartQuantities[menu.id] ?? 1;
                                return OrderItem(
                                  orderId: 0, // Set this dynamically later if required
                                  menuId: menu.id!,
                                  menuName: menu.menuname,
                                  quantity: quantity,
                                  price: menu.price,
                                );
                              }).toList();

                              String orderNumber = await orderService.placeOrder(customerName, orderItems, tableNumber: tableNumber);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Order place successfully!"),
                                  backgroundColor: Colors.green,),
                                );
                                if (onOrderPlaced != null) {
                                  onOrderPlaced();
                                }
                                Navigator.of(context).pop(); // Close cart dialog
                                // Show receipt dialog after closing cart dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => ReceiptDialog(
                                    customerName: customerName,
                                    tableNumber: tableNumber,
                                    orders: orderItems,
                                    totalPrice: totalPrice,
                                    orderNumber: orderNumber,
                                  ),
                                );
                              }
                            } catch (e) {
                              print("Checkout error: $e"); // Fixed error logging
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to save order: $e")),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.payment, color: Colors.white, size: 18),
                          label: const Text(
                            "Checkout",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
