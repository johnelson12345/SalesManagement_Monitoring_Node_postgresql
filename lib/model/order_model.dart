class Order {
  final int? id; // Nullable for creating new orders
  final String customerName;
  final double totalPrice;
  final DateTime orderDate;

  Order({
    this.id,
    required this.customerName,
    required this.totalPrice,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      totalPrice: double.parse(json['total_price'].toString()),
      orderDate: DateTime.parse(json['order_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'total_price': totalPrice,
      'order_date': orderDate.toIso8601String(),
    };
  }
}