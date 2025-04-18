import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/features/cocina/widgets/kanban_column.dart';

class CocinaHomeScreen extends StatelessWidget {
  final PedidoService _pedidoService = PedidoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos - Kanban'),
      ),
      body: Row(
        children: [
          KanbanColumn(
            title: 'Pendientes',
            estado: 'Pendiente',
            onEstadoCambiado: (pedidoId) {
              _pedidoService.actualizarEstadoPedido(
                  pedidoId, 'En Proceso', 'meseroId_placeholder');
            },
          ),
          KanbanColumn(
            title: 'En Proceso',
            estado: 'En Proceso',
            onEstadoCambiado: (pedidoId) {
              _pedidoService.actualizarEstadoPedido(
                  pedidoId, 'Listo', 'meseroId_placeholder');
              NotificationService().notificarMesero(
                  'meseroId_placeholder', 'El pedido $pedidoId está listo.');
            },
          ),
          KanbanColumn(
            title: 'Listos',
            estado: 'Listo',
            onEstadoCambiado: null,
          ),
        ],
      ),
    );
  }
}
