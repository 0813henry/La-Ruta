import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import '../model/pedido_model.dart';

// Este archivo contiene el servicio para gestionar los pedidos en la base de datos.

class PedidoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearPedido(OrderModel pedido) async {
    await _firestore.collection('pedidos').add(pedido.toMap());
    NotificationService().notificarCocina('Nuevo pedido creado: ${pedido.id}');
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
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return OrderModel.fromMap(doc.data(), doc.id); // Pasar el ID
            } catch (e) {
              debugPrint('Error al mapear pedido: $e');
              return null; // Manejar errores de mapeo
            }
          })
          .where((pedido) => pedido != null)
          .cast<OrderModel>()
          .toList();
    });
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

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> actualizarEstadoPedido(
      String pedidoId, String nuevoEstado, String meseroId) async {
    try {
      // Verificar si el documento existe antes de actualizar
      final pedidoDoc = _firestore.collection('pedidos').doc(pedidoId);
      final pedidoSnapshot = await pedidoDoc.get();

      if (!pedidoSnapshot.exists) {
        throw Exception('El pedido con ID $pedidoId no existe.');
      }

      // Actualizar el estado del pedido
      await pedidoDoc.update({'estado': nuevoEstado});
      debugPrint('Estado del pedido $pedidoId actualizado a $nuevoEstado');

      // Enviar notificación al mesero si el estado es "Listo"
      if (nuevoEstado == 'Listo') {
        NotificationService().notificarMesero(
          meseroId,
          'El pedido $pedidoId está listo.',
        );
      }
    } catch (e) {
      debugPrint('Error al actualizar el estado del pedido: $e');
      throw Exception('No se pudo actualizar el estado del pedido.');
    }
  }

  Future<void> cerrarMesa(String mesaId, String cajeroId) async {
    final pedidos = await _firestore
        .collection('pedidos')
        .where('cliente', isEqualTo: 'Mesa $mesaId')
        .get();

    for (var pedido in pedidos.docs) {
      await pedido.reference.update({'estado': 'Listo para pagar'});
    }

    // Notify the cashier
    NotificationService().notificarCajero(
        cajeroId, 'Los pedidos de la mesa $mesaId están listos para pagar.');

    // Ensure the updated orders are reflected in the "orders" collection
    for (var pedido in pedidos.docs) {
      final pedidoData = pedido.data();
      await _firestore.collection('orders').doc(pedido.id).set({
        ...pedidoData,
        'estado': 'Listo para pagar',
      });
    }
  }

  Future<List<OrderItem>> obtenerProductosPorMesa(String mesaId) async {
    final snapshot = await _firestore
        .collection('pedidos')
        .where('cliente', isEqualTo: 'Mesa $mesaId')
        .get();

    if (snapshot.docs.isEmpty) return [];

    return snapshot.docs
        .expand((doc) => (doc.data()['items'] as List)
            .map((item) => OrderItem.fromMap(item as Map<String, dynamic>)))
        .toList();
  }
}
