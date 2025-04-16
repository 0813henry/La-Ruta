class UserModel {
  String uid;
  String email;
  String name;
  String role; // admin, cajero, mesero, cocina
  String phone; // Número de teléfono
  String color; // Color favorito
  bool isActive; // Estado del usuario

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.phone,
    required this.color,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'color': color,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
      phone: map['phone'] ?? '',
      color: map['color'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}
