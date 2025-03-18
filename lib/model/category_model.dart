class Category {
  final int? id;
  final String name;
  final String code;

  Category({this.id, required this.name, required this.code});

  // Convert JSON to Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'], // Ensure 'id' is correctly assigned
      name: json['name'],
      code: json['code'],
    );
  }

  // Convert Category object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include 'id' if it's needed for updates
      'name': name,
      'code': code,
    };
  }
}
