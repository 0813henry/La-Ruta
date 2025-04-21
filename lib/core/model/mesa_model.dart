class Mesa {
  String id;
  String nombre; // Nombre de la mesa
  String estado; // Libre, Ocupada, Reservada
  int capacidad;
  String tipo; // Principal, VIP, etc.

  Mesa({
    required this.id,
    this.nombre = 'Mesa sin nombre', // Default value if not provided
    required this.estado,
    required this.capacidad,
    required this.tipo,
  });

  factory Mesa.fromMap(Map<String, dynamic> data, String documentId) {
    if (documentId.isEmpty) {
      throw Exception('Error: El ID del documento está vacío en fromMap.');
    }
    return Mesa(
      id: documentId,
      nombre:
          data['nombre'] ?? 'Mesa sin nombre', // Default to 'Mesa sin nombre'
      estado: data['estado'] ?? 'Libre',
      capacidad: data['capacidad'] ?? 0,
      tipo: data['tipo'] ?? 'Principal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
      'capacidad': capacidad,
      'tipo': tipo,
    };
  }
}
