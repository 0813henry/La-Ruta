import 'package:cloud_firestore/cloud_firestore.dart';

class Gasto {
  final String id;
  final String? imagenUrl;
  final String descripcion;
  final double valor;
  final DateTime fecha;

  Gasto({
    required this.id,
    this.imagenUrl,
    required this.descripcion,
    required this.valor,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagenUrl': imagenUrl,
      'descripcion': descripcion,
      'valor': valor,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  factory Gasto.fromMap(Map<String, dynamic> map, String documentId) {
    return Gasto(
      id: documentId,
      imagenUrl: map['imagenUrl'],
      descripcion: map['descripcion'],
      valor: (map['valor'] as num).toDouble(),
      fecha: (map['fecha'] as Timestamp).toDate(),
    );
  }

  Gasto copyWith({String? imagenUrl}) {
    return Gasto(
      id: id,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      descripcion: descripcion,
      valor: valor,
      fecha: fecha,
    );
  }
}
