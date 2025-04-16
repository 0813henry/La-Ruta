import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/transaccion_model.dart' as transaccion_model;

class CajaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registrarTransaccion(
      transaccion_model.Transaction transaccion) async {
    try {
      if (transaccion.id.isEmpty) {
        throw Exception('El ID de la transacción no puede estar vacío.');
      }
      await _firestore
          .collection('transacciones')
          .doc(transaccion.id)
          .set(transaccion.toMap());
    } catch (e) {
      print('Error al registrar la transacción: $e');
      rethrow;
    }
  }

  Stream<List<transaccion_model.Transaction>> obtenerTransacciones() {
    return _firestore.collection('transacciones').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => transaccion_model.Transaction.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<transaccion_model.Transaction>> obtenerTransaccionesPorFecha(
      DateTime fecha) {
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(Duration(days: 1));
    return _firestore
        .collection('transacciones')
        .where('date', isGreaterThanOrEqualTo: inicio)
        .where('date', isLessThan: fin)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => transaccion_model.Transaction.fromMap(doc.data()))
          .toList();
    });
  }
}
