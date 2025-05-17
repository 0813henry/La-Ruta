import 'package:uuid/uuid.dart';

class Product {
  String id;
  String name;
  String descripcion;
  double price;
  String category;
  int stock;
  String? imageUrl;
  int preparationTime; // Nuevo campo

  Product({
    String? id,
    required this.name,
    required this.descripcion,
    required this.price,
    required this.category,
    required this.stock,
    this.imageUrl,
    required this.preparationTime, // Nuevo campo
  }) : id = id ?? const Uuid().v4();

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      descripcion: data['descripcion'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'],
      preparationTime: data['preparationTime'] ?? 0, // Nuevo campo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'descripcion': descripcion,
      'price': price,
      'category': category,
      'stock': stock,
      'imageUrl': imageUrl,
      'preparationTime': preparationTime, // Nuevo campo
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? descripcion,
    double? price,
    String? category,
    int? stock,
    String? imageUrl,
    int? preparationTime, // Nuevo campo
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      descripcion: descripcion ?? this.descripcion,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      preparationTime: preparationTime ?? this.preparationTime, // Nuevo campo
    );
  }
}
