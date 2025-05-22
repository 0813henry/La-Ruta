import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/core/services/producto_service.dart';
import '../model/pedido_model.dart';

// Este archivo contiene el servicio para gestionar los pedidos en la base de datos.

class PedidoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore getFirestore() => _firestore;

  Future<void> crearPedido(OrderModel pedido) async {
    try {
      final pedidoData = pedido.toMap();
      await _firestore.collection('pedidos').doc(pedido.id).set(pedidoData);
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

  Future<void> confirmarPedido({
    required BuildContext context,
    required OrderModel? pedidoExistente,
    required String mesaId,
    required List<OrderItem> carrito,
    required String cliente,
    required String tipo,
  }) async {
    final productoService = ProductoService();
    bool stockOk = true;
    String? errorMsg;
    Map<String, int> stockCambios = {};
    Map<String, int> stockActual = {};

    if (pedidoExistente != null) {
      final original = <String, int>{};
      for (final item in pedidoExistente.items) {
        original[item.idProducto] =
            (original[item.idProducto] ?? 0) + item.cantidad;
      }

      final nuevo = <String, int>{};
      for (final item in carrito) {
        nuevo[item.idProducto] = (nuevo[item.idProducto] ?? 0) + item.cantidad;
      }

      final ids = {...original.keys, ...nuevo.keys};
      for (final id in ids) {
        final cantOriginal = original[id] ?? 0;
        final cantNueva = nuevo[id] ?? 0;
        stockCambios[id] = cantNueva - cantOriginal;
      }
    } else {
      for (final item in carrito) {
        stockCambios[item.idProducto] =
            (stockCambios[item.idProducto] ?? 0) + item.cantidad;
      }
    }

    for (final entry in stockCambios.entries) {
      final idProducto = entry.key;
      final cambio = entry.value;
      final producto = await productoService.obtenerProductoPorId(idProducto);
      if (producto == null) {
        stockOk = false;
        errorMsg = 'El producto con ID "$idProducto" no está disponible.';
        break;
      }
      stockActual[idProducto] = producto.stock;
      if (cambio > 0 && cambio > producto.stock) {
        stockOk = false;
        errorMsg =
            'No hay suficiente stock para "${producto.name}". Disponible: ${producto.stock}, solicitado extra: $cambio.';
        break;
      }
    }

    if (!stockOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg ?? 'Stock insuficiente')),
      );
      return;
    }

    for (final entry in stockCambios.entries) {
      final idProducto = entry.key;
      final cambio = entry.value;
      final stock = stockActual[idProducto]!;
      final nuevoStock = stock - cambio;
      await productoService.actualizarProductoStock(idProducto, nuevoStock);
    }

    final total = carrito.fold(0.0, (sum, item) {
      final adicionalesTotal = item.adicionales.fold(
        0.0,
        (sum, adicional) => sum + (adicional['price'] as double),
      );
      return sum + (item.precio + adicionalesTotal) * item.cantidad;
    });

    if (pedidoExistente != null) {
      final pedidoModificado = pedidoExistente.copyWith(
        cliente: cliente,
        tipo: tipo,
        items: List<OrderItem>.from(carrito),
        total: total,
      );

      try {
        await actualizarPedido(pedidoModificado);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido modificado exitosamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al modificar el pedido: $e')),
        );
      }
    } else {
      final nuevoPedido = OrderModel(
        cliente: cliente,
        items: List<OrderItem>.from(carrito),
        total: total,
        estado: 'Pendiente',
        tipo: tipo,
        startTime: DateTime.now(),
      );

      try {
        await crearPedido(nuevoPedido);
        await enviarSMS('Pedido enviado exitosamente.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido enviado exitosamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el pedido: $e')),
        );
      }
    }
  }
}
