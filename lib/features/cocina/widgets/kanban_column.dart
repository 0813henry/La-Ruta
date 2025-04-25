import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/features/cocina/widgets/pedido_detail_dialog.dart';
import 'package:restaurante_app/features/cocina/widgets/pedido_kitchen_card.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final String estado;
  final Function(String, String)? onEstadoCambiado;

  KanbanColumn({
    required this.title,
    required this.estado,
    this.onEstadoCambiado,
  });

  final PedidoService _pedidoService = PedidoService();

  void _mostrarDetallesPedido(BuildContext context, OrderModel pedido) {
    showDialog(
      context: context,
      builder: (context) => PedidoDetailDialog(
        pedido: pedido,
        onEstadoCambiado: onEstadoCambiado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Reducir espacio entre columnas
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: StreamBuilder(
                  stream: _pedidoService.obtenerPedidosPorEstado(estado),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final pedidos = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidos[index];
                        return GestureDetector(
                          onTap: () => _mostrarDetallesPedido(context, pedido),
                          child: PedidoKitchenCard(
                            pedidoId: pedido.id ?? 'ID no disponible',
                            cliente: pedido.cliente,
                            estado: pedido.estado,
                            startTime: pedido.startTime ?? DateTime.now(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
