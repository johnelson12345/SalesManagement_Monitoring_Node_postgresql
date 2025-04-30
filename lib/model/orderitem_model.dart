class OrderItem {
  final int? id; // Nullable for creating new items
  final int orderId;
  final int menuId;
  final String menuName; // For UI representation
  final int quantity;
  final double price;

  OrderItem({
    this.id,
    required this.orderId,
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      menuId: json['menu_id'],
      menuName: json['menuname'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_id': menuId,
      'menuname': menuName,
      'quantity': quantity,
      'price': price,
    };
  }
}