class Mesa {
  String id;
  String estado; // Libre, Ocupada, Reservada
  int capacidad;
  String tipo; // Principal, VIP, etc.

  Mesa({
    required this.id,
    required this.estado,
    required this.capacidad,
    required this.tipo,
  });

  factory Mesa.fromMap(Map<String, dynamic> data, String documentId) {
    return Mesa(
      id: documentId,
      estado: data['estado'] ?? 'Libre',
      capacidad: data['capacidad'] ?? 0,
      tipo: data['tipo'] ?? 'Principal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estado': estado,
      'capacidad': capacidad,
      'tipo': tipo,
    };
  }
}
