import 'package:uuid/uuid.dart';

class OrderModel {
  String id;
  String cliente;
  List<OrderItem> items;
  double total;
  String estado;
  String tipo; // Local, Domicilio, VIP
  DateTime? startTime;
  Map<String, List<OrderItem>>? divisiones; // <-- nuevo campo
  String? idDivisiones; // <-- nuevo campo

  OrderModel({
    String? id,
    required this.cliente,
    required this.items,
    required this.total,
    required this.estado,
    required this.tipo,
    this.startTime,
    this.divisiones, // <-- nuevo campo
    this.idDivisiones, // <-- nuevo campo
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'estado': estado,
      'tipo': tipo,
      'startTime': startTime?.toIso8601String(),
      'divisiones': divisiones
          ?.map((k, v) => MapEntry(k, v.map((item) => item.toMap()).toList())),
      'idDivisiones': idDivisiones, // <-- nuevo campo
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return OrderModel(
      id: map['id'] ?? documentId, // Usa el id del mapa o el documentId
      cliente: map['cliente'],
      items: List<OrderItem>.from(
          map['items'].map((item) => OrderItem.fromMap(item))),
      total: (map['total'] as num).toDouble(),
      estado: map['estado'],
      tipo: map['tipo'],
      startTime:
          map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      divisiones: map['divisiones'] != null
          ? (map['divisiones'] as Map<String, dynamic>).map((k, v) => MapEntry(
              k,
              List<OrderItem>.from(
                  (v as List).map((item) => OrderItem.fromMap(item)))))
          : null,
      idDivisiones: map['idDivisiones'], // <-- nuevo campo
    );
  }

  OrderModel copyWith({
    String? id,
    String? cliente,
    List<OrderItem>? items,
    double? total,
    String? estado,
    String? tipo,
    String? mesaId,
    DateTime? startTime,
    Map<String, List<OrderItem>>? divisiones,
    String? idDivisiones, // <-- nuevo campo
    // agrega otros campos si es necesario
  }) {
    return OrderModel(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      items: items ?? this.items,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      tipo: tipo ?? this.tipo,
      startTime: startTime ?? this.startTime,
      divisiones: divisiones ?? this.divisiones,
      idDivisiones: idDivisiones ?? this.idDivisiones, // <-- nuevo campo
      // agrega otros campos si es necesario
    );
  }
}

class OrderItem {
  String nombre;
  int cantidad;
  double precio;
  String descripcion;
  List<Map<String, dynamic>> adicionales; // List of adicionales

  OrderItem({
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.descripcion,
    this.adicionales = const [], // Default to an empty list
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'precio': precio,
      'descripcion': descripcion,
      'adicionales': adicionales, // Save adicionales as a list of maps
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      nombre: map['nombre'],
      cantidad: map['cantidad'],
      precio: (map['precio'] as num).toDouble(),
      descripcion: map['descripcion'],
      adicionales: List<Map<String, dynamic>>.from(map['adicionales'] ?? []),
    );
  }

  get id => null;
}
