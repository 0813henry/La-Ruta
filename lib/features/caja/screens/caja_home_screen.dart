import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import '../widgets/menu_lateral_caja.dart';
import 'pago_screen.dart';

class CajaHomeScreen extends StatelessWidget {
  final PedidoService _pedidoService = PedidoService();

  @override
  Widget build(BuildContext context) {
    NotificationService().escucharNotificacionesCocina((mesaId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesa $mesaId lista para pagar')),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text('Caja - Pedidos Listos')),
      drawer: MenuLateralCaja(),
      body: StreamBuilder<List<OrderModel>>(
        stream: _pedidoService.obtenerPedidosPorEstado('Listo para pagar'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return Center(child: Text('No hay pedidos listos para pagar.'));
          }
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return ListTile(
                title: Text('Mesa: ${pedido.cliente}'),
                subtitle: Text('Total: \$${pedido.total.toStringAsFixed(2)}'),
                trailing: ElevatedButton(
                  child: Text('Pagar'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PagoScreen(pedido: pedido),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
