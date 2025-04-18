import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/features/cocina/widgets/timer_progress_widget.dart';

class TiemposScreen extends StatelessWidget {
  final PedidoService _pedidoService = PedidoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiempos de Preparación'),
      ),
      body: StreamBuilder(
        stream: _pedidoService.obtenerPedidosPorEstado('En Proceso'),
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
              return ListTile(
                title: Text('Pedido ${pedido.id}'),
                subtitle: Text('Cliente: ${pedido.cliente}'),
                trailing: TimerProgressWidget(
                  startTime: pedido.startTime ?? DateTime.now(),
                  maxDuration: Duration(minutes: 30),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
