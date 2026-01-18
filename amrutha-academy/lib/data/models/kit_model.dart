class KitModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final bool inStock;
  final int stockQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.inStock,
    required this.stockQuantity,
    this.createdAt,
    this.updatedAt,
  });

  factory KitModel.fromJson(Map<String, dynamic> json) {
    return KitModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? json['image'],
      inStock: json['inStock'] ?? json['in_stock'] ?? true,
      stockQuantity: json['stockQuantity'] ?? json['stock_quantity'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

