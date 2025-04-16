import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final String estado;
  final Function(String)? onEstadoCambiado;

  KanbanColumn({
    required this.title,
    required this.estado,
    this.onEstadoCambiado,
  });

  final PedidoService _pedidoService = PedidoService();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
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
                    return Card(
                      child: ListTile(
                        title: Text('Pedido ${pedido.id}'),
                        subtitle: Text('Cliente: ${pedido.cliente}'),
                        trailing: onEstadoCambiado != null
                            ? IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () => onEstadoCambiado!(pedido.id!),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
