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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Pedido ${pedido.id}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: ${pedido.cliente}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Estado: ${pedido.estado}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Divider(),
            Text(
              'Items:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...pedido.items.map((item) => ListTile(
                  title: Text(
                    '${item.nombre} x${item.cantidad}',
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    'Notas: ${item.descripcion}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )),
            Divider(),
            SizedBox(height: 20),
            Text(
              'Total: \$${pedido.total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
