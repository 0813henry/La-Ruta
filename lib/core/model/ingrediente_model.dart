class Ingredient {
  String id;
  String name;
  int quantity;
  String unit;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromMap(Map<String, dynamic> data, String documentId) {
    return Ingredient(
      id: documentId,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      unit: data['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
