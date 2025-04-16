import 'package:cloud_firestore/cloud_firestore.dart';
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
      await _firestore.collection('mesas').add(mesa.toMap());
    } catch (e) {
      throw Exception('Error al agregar la mesa: $e');
    }
  }

  Future<void> actualizarEstado(String mesaId, String nuevoEstado) async {
    await _firestore
        .collection('mesas')
        .doc(mesaId)
        .update({'estado': nuevoEstado});
  }

  Future<void> reservarMesa(String mesaId) async {
    await actualizarEstado(mesaId, 'Reservada');
  }
}
