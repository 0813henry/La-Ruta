import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import '../model/pedido_model.dart';

// Este archivo contiene el servicio para gestionar los pedidos en la base de datos.

class PedidoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearPedido(OrderModel pedido) async {
    try {
      final pedidoData = pedido.toMap();
      await _firestore.collection('pedidos').add(pedidoData);
      NotificationService()
          .notificarCocina('Nuevo pedido creado: ${pedido.id}');
    } catch (e) {
      throw Exception('Error al crear el pedido: $e');
    }
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
    try {
      return _firestore
          .collection('pedidos')
          .where('estado', isEqualTo: estado)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return OrderModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                debugPrint('Error al mapear pedido: $e');
                return null; // Ignorar pedidos con errores
              }
            })
            .where((pedido) => pedido != null)
            .cast<OrderModel>()
            .toList();
      });
    } catch (e) {
      debugPrint('Error al obtener pedidos por estado: $e');
      return Stream.error('Error al obtener pedidos por estado: $e');
    }
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

  Future<void> enviarSMS(String mensaje) async {
    try {
      // Replace with actual SMS sending logic
      debugPrint('Enviando SMS: $mensaje');
    } catch (e) {
      debugPrint('Error al enviar SMS: $e');
    }
  }

  Future<Map<String, int>> obtenerProductosMasVendidos() async {
    final snapshot = await _firestore.collection('pedidos').get();
    final productos = <String, int>{};

    for (var doc in snapshot.docs) {
      final items = (doc.data()['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
      for (var item in items) {
        productos[item.nombre] = (productos[item.nombre] ?? 0) + item.cantidad;
      }
    }

    return productos;
  }

  Future<Map<String, double>> obtenerVentasPorMesa() async {
    final snapshot = await _firestore.collection('pedidos').get();
    final ventasPorMesa = <String, double>{};

    for (var doc in snapshot.docs) {
      final cliente = doc.data()['cliente'] as String;
      final total = (doc.data()['total'] as num).toDouble();
      ventasPorMesa[cliente] = (ventasPorMesa[cliente] ?? 0) + total;
    }

    return ventasPorMesa;
  }

  Future<double> obtenerGananciasPorRango(DateTime inicio, DateTime fin) async {
    try {
      final snapshot = await _firestore
          .collection('pedidos')
          .where('startTime', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('startTime', isLessThanOrEqualTo: fin.toIso8601String())
          .get();

      return snapshot.docs.fold<double>(0.0, (total, doc) {
        try {
          return total + (doc.data()['total'] as num).toDouble();
        } catch (e) {
          debugPrint('Error al procesar el total de un pedido: $e');
          return total; // Ignorar el pedido con error
        }
      });
    } catch (e) {
      debugPrint('Error al obtener ganancias por rango: $e');
      throw Exception('Error al obtener ganancias por rango: $e');
    }
  }

  Future<double> obtenerGananciasPorEstadoYPago(
      DateTime inicio, DateTime fin) async {
    try {
      final snapshot = await _firestore
          .collection('pedidos')
          .where('estado', isEqualTo: 'Pagado') // Filtrar por estado "Pagado"
          .where('startTime', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('startTime', isLessThanOrEqualTo: fin.toIso8601String())
          .get();

      return snapshot.docs.fold<double>(0.0, (total, doc) {
        try {
          return total +
              (doc.data()['total'] as num).toDouble(); // Sumar el total
        } catch (e) {
          debugPrint('Error al procesar el total de un pedido: $e');
          return total; // Ignorar el pedido con error
        }
      });
    } catch (e) {
      debugPrint('Error al obtener ganancias por estado y rango: $e');
      debugPrint('Consulta fallida: estado="Pagado", rango=[$inicio, $fin]');
      throw Exception('Error al obtener ganancias por estado y rango: $e');
    }
  }

  Future<void> actualizarPedido(OrderModel pedido) async {
    if (pedido.id == null || pedido.id!.isEmpty) {
      throw Exception('El pedido no tiene un ID válido.');
    }
    try {
      await _firestore
          .collection('pedidos')
          .doc(pedido.id)
          .update(pedido.toMap());
    } catch (e) {
      throw Exception('Error al actualizar el pedido: $e');
    }
  }
}
