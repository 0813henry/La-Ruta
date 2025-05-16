import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/widgets/tarjeta_informativa.dart';
import 'package:restaurante_app/core/utils/constantes.dart';

class KitchenOrdersScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  KitchenOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos en Cocina'),
        backgroundColor: Color(primaryColor),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _firebaseService.getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PedidoDetailScreen(pedido: order),
                    ),
                  );
                },
                child: CardWidget(
                  title: 'Mesa: ${order.cliente}',
                  description:
                      'Total: \$${order.total.toStringAsFixed(2)}\nEstado: ${order.estado}',
                  icon: Icons.restaurant_menu,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PedidoDetailScreen extends StatelessWidget {
  final OrderModel pedido;

  const PedidoDetailScreen({required this.pedido, super.key});

  double _divisionSubtotal(List<OrderItem> items) {
    double subtotal = 0.0;
    for (var item in items) {
      final adicionalesTotal = item.adicionales.fold(
        0.0,
        (sum, adicional) => sum + (adicional['price'] as double),
      );
      subtotal += (item.precio + adicionalesTotal) * item.cantidad;
    }
    return subtotal;
  }

  double _totalGeneral() {
    double total = _divisionSubtotal(pedido.items);
    if (pedido.divisiones != null && pedido.divisiones!.isNotEmpty) {
      pedido.divisiones!.forEach((_, items) {
        total += _divisionSubtotal(items);
      });
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final divisiones = pedido.divisiones ?? {};
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Pedido'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pedido.cliente,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pedido.estado,
                          style: TextStyle(
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Tipo: ${pedido.tipo}', style: TextStyle(fontSize: 16)),
                  Divider(height: 24),
                  Text('Productos principales:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ...pedido.items.map((item) {
                    final adicionalesTotal = item.adicionales.fold(
                      0.0,
                      (sum, adicional) => sum + (adicional['price'] as double),
                    );
                    final itemTotal =
                        (item.precio + adicionalesTotal) * item.cantidad;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text('${item.nombre} x${item.cantidad}')),
                          Text('\$${itemTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Subtotal: \$${_divisionSubtotal(pedido.items).toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (divisiones.isNotEmpty) ...[
                    Divider(height: 24),
                    Text('Divisiones:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    ...divisiones.entries.map((entry) {
                      final division = entry.key;
                      final productos = entry.value;
                      final subtotal = _divisionSubtotal(productos);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          color: Colors.grey[100],
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.group,
                                        color: const Color.fromARGB(
                                            255, 242, 243, 243)),
                                    SizedBox(width: 8),
                                    Text('División: $division',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                ...productos.map((item) {
                                  final adicionalesTotal =
                                      item.adicionales.fold(
                                    0.0,
                                    (sum, adicional) =>
                                        sum + (adicional['price'] as double),
                                  );
                                  final itemTotal =
                                      (item.precio + adicionalesTotal) *
                                          item.cantidad;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                                '${item.nombre} x${item.cantidad}')),
                                        Text(
                                            '\$${itemTotal.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  );
                                }),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                  Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL GENERAL: \$${_totalGeneral().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
