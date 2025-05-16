import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/features/cocina/widgets/pedido_detail_dialog.dart';
import 'package:restaurante_app/features/cocina/widgets/pedido_kitchen_card.dart';

class KanbanColumn extends StatefulWidget {
  final String title;
  final String estado;
  final Function(String, String)? onEstadoCambiado;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.estado,
    this.onEstadoCambiado,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {
  final PedidoService _pedidoService = PedidoService();
  String _tipoFiltro = 'Todos';

  void _mostrarDetallesPedido(BuildContext context, OrderModel pedido) {
    showDialog(
      context: context,
      builder: (context) => PedidoDetailDialog(
        pedido: pedido,
        onEstadoCambiado: widget.onEstadoCambiado,
      ),
    );
  }

  List<OrderModel> _ordenarPedidos(List<OrderModel> pedidos) {
    // VIP primero, luego por startTime ascendente
    pedidos.sort((a, b) {
      if (a.tipo.toLowerCase() == 'vip' && b.tipo.toLowerCase() != 'vip') {
        return -1;
      }
      if (a.tipo.toLowerCase() != 'vip' && b.tipo.toLowerCase() == 'vip') {
        return 1;
      }
      final aTime = a.startTime ?? DateTime.now();
      final bTime = b.startTime ?? DateTime.now();
      return aTime.compareTo(bTime);
    });
    return pedidos;
  }

  @override
  Widget build(BuildContext context) {
    final tipos = ['Todos', 'Local', 'Domicilio', 'VIP'];
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            // Filtros por tipo de pedido
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tipos.map((tipo) {
                  final isSelected = _tipoFiltro == tipo;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ChoiceChip(
                      label: Text(tipo),
                      selected: isSelected,
                      selectedColor: Colors.blue[100],
                      onSelected: (_) {
                        setState(() {
                          _tipoFiltro = tipo;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: StreamBuilder<List<OrderModel>>(
                  stream: _pedidoService.obtenerPedidosPorEstado(widget.estado),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var pedidos = snapshot.data ?? [];
                    // Filtrar por tipo si corresponde
                    if (_tipoFiltro != 'Todos') {
                      pedidos = pedidos
                          .where((p) =>
                              p.tipo.toLowerCase() == _tipoFiltro.toLowerCase())
                          .toList();
                    }
                    pedidos = _ordenarPedidos(pedidos);
                    if (pedidos.isEmpty) {
                      return Center(child: Text('No hay pedidos.'));
                    }
                    return ListView.builder(
                      itemCount: pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidos[index];
                        return GestureDetector(
                          onTap: () => _mostrarDetallesPedido(context, pedido),
                          child: PedidoKitchenCard(
                            cliente: pedido.cliente,
                            estado: pedido.estado,
                            startTime: pedido.startTime ?? DateTime.now(),
                            tipo: pedido.tipo,
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
