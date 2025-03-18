
class Menu {
  final int? id;
  final String menuname;
  final int categoryid;
  final String? description;
  final double price;
  final String status;
  final String? image;

  // Constructor
  Menu({
    this.id,
    required this.menuname,
    required this.categoryid,
    this.description,
    required this.price,
    required this.status,
    this.image,
  });

  // From JSON (used when receiving data from the API)
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      menuname: json['menuname'],
      categoryid: json['categoryid'],
      description: json['description'],
       price: (json['price'] is num) ? json['price'].toDouble() : double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status'],
      image: json['image'],
    );
  }

  // To JSON (used when sending data to the API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuname': menuname,
      'categoryid': categoryid,
      'description': description,
      'price': price,
      'status': status,
      'image': image,
    };
  }
}
