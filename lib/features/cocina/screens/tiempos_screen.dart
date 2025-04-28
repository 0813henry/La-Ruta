import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/features/cocina/widgets/menu_lateral_cocina.dart';
import 'package:restaurante_app/features/cocina/widgets/timer_progress.dart';

class TiemposScreen extends StatelessWidget {
  final PedidoService _pedidoService = PedidoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiempos de Preparación'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Permitir regresar a la pantalla anterior
          },
        ),
      ),
      drawer: MenuLateralCocina(),
      body: StreamBuilder<List<OrderModel>>(
        stream: _pedidoService.obtenerPedidosPorEstado('En Proceso'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar los pedidos: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay pedidos en proceso.'));
          }
          final pedidos = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return ListTile(
                  title: Text('Pedido ${pedido.id ?? 'Sin ID'}'),
                  subtitle: Text('Cliente: ${pedido.cliente ?? 'Desconocido'}'),
                  trailing: TimerProgress(
                    startTime: pedido.startTime ?? DateTime.now(),
                    maxDuration: Duration(minutes: 30),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
