import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/mesa_model.dart';

// Este archivo contiene el servicio para gestionar las mesas en la base de datos.

class MesaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Mesa>> obtenerMesas() {
    return _firestore.collection('mesas').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Mesa.fromMap(doc.data(), doc.id)).toList());
  }

  Future<List<Mesa>> obtenerMesasUnaVez() async {
    final snapshot = await _firestore.collection('mesas').get();
    return snapshot.docs
        .map((doc) => Mesa.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> agregarMesa(Mesa mesa) async {
    try {
      if (mesa.id.isEmpty) {
        debugPrint(
            'Advertencia: El ID de la mesa está vacío. Generando un nuevo ID.');
        mesa.id =
            _firestore.collection('mesas').doc().id; // Generar un ID único
      }
      await _firestore.collection('mesas').doc(mesa.id).set(mesa.toMap());
      debugPrint('Mesa agregada con ID: ${mesa.id}');
    } catch (e) {
      debugPrint('Error al agregar la mesa: $e');
      throw Exception('Error al agregar la mesa: $e');
    }
  }

  Future<void> actualizarEstado(String mesaId, String nuevoEstado) async {
    if (mesaId.isEmpty) {
      debugPrint('Error: El ID de la mesa está vacío en actualizarEstado.');
      throw Exception('El ID de la mesa no puede estar vacío.');
    }
    await _firestore
        .collection('mesas')
        .doc(mesaId)
        .update({'estado': nuevoEstado});
  }

  Future<void> reservarMesa(String mesaId) async {
    await actualizarEstado(mesaId, 'Reservada');
  }

  Future<void> actualizarNombre(String mesaId, String nuevoNombre) async {
    if (mesaId.isEmpty) {
      throw Exception('El ID de la mesa no puede estar vacío.');
    }
    await _firestore
        .collection('mesas')
        .doc(mesaId)
        .update({'nombre': nuevoNombre});
  }
}
