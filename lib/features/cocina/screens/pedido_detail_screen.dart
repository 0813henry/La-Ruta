import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/widgets/tarjeta_informativa.dart';
import 'package:restaurante_app/core/utils/constantes.dart';

class KitchenOrdersScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

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
              return CardWidget(
                title: 'Mesa: ${order.cliente}',
                description:
                    'Total: \$${order.total.toStringAsFixed(2)}\nEstado: ${order.estado}',
                icon: Icons.restaurant_menu,
              );
            },
          );
        },
      ),
    );
  }
}
