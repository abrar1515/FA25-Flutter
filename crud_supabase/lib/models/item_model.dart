class Item {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Item to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
    };
  }

  // Create Item from JSON (Supabase response)
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
