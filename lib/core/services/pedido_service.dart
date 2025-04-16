import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import '../model/pedido_model.dart';

// Este archivo contiene el servicio para gestionar los pedidos en la base de datos.

class PedidoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearPedido(OrderModel pedido) async {
    await _firestore.collection('pedidos').add(pedido.toMap());
  }

  Stream<List<OrderModel>> obtenerPedidosPorMesero(String meseroId) {
    return _firestore
        .collection('pedidos')
        .where('meseroId', isEqualTo: meseroId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<OrderModel>> obtenerPedidosPorEstado(String estado) {
    return _firestore
        .collection('pedidos')
        .where('estado', isEqualTo: estado)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<OrderModel>> obtenerTodosLosPedidos() {
    return _firestore.collection('pedidos').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<OrderModel>> obtenerPedidosFiltrados(String estado, String tipo) {
    Query query = _firestore.collection('pedidos');

    if (estado != 'Todos') {
      query = query.where('estado', isEqualTo: estado);
    }
    if (tipo != 'Todos') {
      query = query.where('tipo', isEqualTo: tipo);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> actualizarEstadoPedido(
      String pedidoId, String nuevoEstado, String meseroId) async {
    await _firestore
        .collection('pedidos')
        .doc(pedidoId)
        .update({'estado': nuevoEstado});
    if (nuevoEstado == 'Listo') {
      NotificationService()
          .notificarMesero(meseroId, 'El pedido $pedidoId está listo.');
    }
  }
}
