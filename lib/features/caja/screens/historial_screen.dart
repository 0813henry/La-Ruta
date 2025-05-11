import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/features/caja/widgets/resumen_pago.dart';
import '../widgets/menu_lateral_caja.dart';

class HistorialScreen extends StatelessWidget {
  final PedidoService _pedidoService = PedidoService();

  HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService().escucharNotificacionesCocina((mesaId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesa $mesaId lista para pagado')),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text('Historial de vetas')),
      drawer: MenuLateralCaja(),
      body: StreamBuilder<List<OrderModel>>(
        stream: _pedidoService.obtenerPedidosPorEstado('Pagado'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('Error en el StreamBuilder: ${snapshot.error}');
            return Center(
              child: Text('Error al cargar los pedidos: ${snapshot.error}'),
            );
          }
          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return Center(
                child: Text(
                    'No hay pedidos con estado "Pagado".')); // Fix incorrect message
          }
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return ListTile(
                title: Text('Mesa: ${pedido.cliente}'),
                subtitle: Text('Total: \$${pedido.total.toStringAsFixed(2)}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: ResumenPago(pedido: pedido),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
