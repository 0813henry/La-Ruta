class OrderModel {
  String? id;
  String cliente;
  List<OrderItem> items;
  double total;
  String estado;
  String tipo; // Local, Domicilio, VIP
  DateTime? startTime;

  OrderModel({
    this.id,
    required this.cliente,
    required this.items,
    required this.total,
    required this.estado,
    required this.tipo,
    this.startTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'estado': estado,
      'tipo': tipo,
      'startTime': startTime?.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      cliente: map['cliente'],
      items: List<OrderItem>.from(
          map['items'].map((item) => OrderItem.fromMap(item))),
      total: map['total'],
      estado: map['estado'],
      tipo: map['tipo'],
      startTime:
          map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
    );
  }
}

class OrderItem {
  String nombre;
  int cantidad;
  double precio;
  String descripcion;

  OrderItem({
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.descripcion,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'precio': precio,
      'descripcion': descripcion,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      nombre: map['nombre'],
      cantidad: map['cantidad'],
      precio: map['precio'],
      descripcion: map['descripcion'],
    );
  }
}
