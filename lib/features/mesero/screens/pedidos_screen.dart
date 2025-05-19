import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/features/mesero/widgets/mesero_scaffold_layout.dart';
import 'package:restaurante_app/features/mesero/widgets/orders/search_bar.dart';
import 'package:restaurante_app/features/mesero/widgets/orders/filtros_pedidos.dart';
import 'package:restaurante_app/features/mesero/widgets/orders/pedido_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final PedidoService _pedidoService = PedidoService();
  String _selectedEstado = 'Todos';
  String _selectedTipo = 'Todos';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    NotificationService().escucharNotificacionesCocina((pedidoId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El pedido $pedidoId está listo.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MeseroScaffoldLayout(
      title: const Text('Pedidos Activos'),
      body: Column(
        children: [
          SearchBarPedidos(onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          }),
          FiltrosPedidos(
            selectedEstado: _selectedEstado,
            selectedTipo: _selectedTipo,
            onEstadoChanged: (estado) {
              setState(() {
                _selectedEstado = estado;
              });
            },
            onTipoChanged: (tipo) {
              setState(() {
                _selectedTipo = tipo;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _pedidoService.obtenerPedidosFiltrados(
                _selectedEstado,
                _selectedTipo,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final pedidos = snapshot.data ?? [];
                final filteredPedidos = pedidos
                    .where((pedido) =>
                        pedido.estado.toLowerCase() != 'pagado' &&
                        pedido.cliente.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredPedidos.isEmpty) {
                  return const Center(child: Text('No hay pedidos activos.'));
                }

                return ListView.builder(
                  itemCount: filteredPedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = filteredPedidos[index];
                    return PedidoCard(pedido: pedido);
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
