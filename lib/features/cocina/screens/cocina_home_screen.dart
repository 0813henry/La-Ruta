import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/features/cocina/widgets/kanban_column.dart';
import 'package:restaurante_app/features/cocina/widgets/menu_lateral_cocina.dart';

class CocinaHomeScreen extends StatelessWidget {
  final PedidoService _pedidoService = PedidoService();

  CocinaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos - Kanban'),
      ),
      drawer: MenuLateralCocina(),
      body: Row(
        children: [
          KanbanColumn(
            title: 'Pendientes',
            estado: 'Pendiente',
            onEstadoCambiado: (pedidoId, nuevoEstado) {
              _pedidoService.actualizarEstadoPedido(
                  pedidoId, nuevoEstado, 'meseroId_placeholder');
            },
          ),
          KanbanColumn(
            title: 'En Proceso',
            estado: 'En Proceso',
            onEstadoCambiado: (pedidoId, nuevoEstado) {
              _pedidoService.actualizarEstadoPedido(
                  pedidoId, nuevoEstado, 'meseroId_placeholder');
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
