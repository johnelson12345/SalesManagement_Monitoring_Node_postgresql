class Order {
  final int id;
  final String customerName;
  final double totalPrice;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.totalPrice,
    required this.createdAt,
  });

  // Convert JSON to Order Object
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      totalPrice: json['total_price'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert Order Object to JSON
  Map<String, dynamic> toJson() {
    return {
      "customer_name": customerName,
      "total_price": totalPrice,
    };
  }
}
