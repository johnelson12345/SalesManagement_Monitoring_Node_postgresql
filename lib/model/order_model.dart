import 'orderitem_model.dart';

class Order {
  final int? id; // Nullable for creating new orders
  final String customerName;
  final double totalPrice;
  final DateTime orderDate;
  final List<OrderItem> items;
  final String status; // New status field
  final String? tableNumber; // New table number field

  Order({
    this.id,
    required this.customerName,
    required this.totalPrice,
    required this.orderDate,
    required this.items,
    required this.status,
    this.tableNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List<dynamic>? ?? [];
    List<OrderItem> itemsList = itemsJson.map((item) => OrderItem.fromJson(item)).toList();

    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      totalPrice: double.parse(json['total_price'].toString()),
      orderDate: DateTime.parse(json['order_date']),
      items: itemsList,
      status: json['status'] ?? 'pending', // default to pending if missing
      tableNumber: json['table_number'], // parse table number
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'total_price': totalPrice,
      'order_date': orderDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'table_number': tableNumber, // include table number
    };
  }
}
