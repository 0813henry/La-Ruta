class Product {
  String id;
  String name;
  String descripcion;
  double price;
  String category;
  int stock;
  String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.descripcion,
    required this.price,
    required this.category,
    required this.stock,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      descripcion: data['descripcion'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'],
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
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      descripcion: descripcion ?? this.descripcion,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
