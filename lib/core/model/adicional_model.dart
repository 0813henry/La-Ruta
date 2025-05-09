class Adicional {
  String id;
  String name;
  double price;

  Adicional({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Adicional.fromMap(Map<String, dynamic> data, String documentId) {
    return Adicional(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }
}
