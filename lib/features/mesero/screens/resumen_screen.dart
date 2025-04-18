import 'package:flutter/material.dart';
import '../../../core/services/pedido_service.dart';
import '../../../core/widgets/modules/pedido_item.dart';
import '../../../core/model/pedido_model.dart';
import '../widgets/menu_lateral_mesero.dart';

class ResumenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de Pedidos'),
      ),
      drawer: MenuLateralMesero(),
      body: StreamBuilder<List<OrderModel>>(
        stream: PedidoService().obtenerPedidosPorEstado('Pagado'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return Center(child: Text('No hay pedidos vendidos.'));
          }
          final total = pedidos.fold(
              0.0, (sum, pedido) => sum + pedido.total); // Calcular total
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    return PedidoItem(
                      pedido: pedido,
                      onTap: () {
                        // Acción al seleccionar un pedido
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[200],
                child: Text(
                  'Total Vendido: \$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
