import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/widgets/modules/pedido_item.dart';
import '../widgets/menu_lateral_mesero.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final PedidoService _pedidoService = PedidoService();
  String _selectedEstado = 'Todos'; // Filtro por estado
  String _selectedTipo = 'Todos'; // Filtro por tipo

  @override
  void initState() {
    super.initState();
    NotificationService().escucharNotificacionesCocina((pedidoId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El pedido $pedidoId está listo.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos Activos'),
        actions: [
          DropdownButton<String>(
            value: _selectedEstado,
            items: [
              'Todos',
              'Pendientes',
              'Confirmado',
              'Producción',
              'Listo',
              'Listo Reparto',
              'Recoger',
              'Salida Entrega'
            ]
                .map((estado) => DropdownMenuItem(
                      value: estado,
                      child: Text(estado),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedEstado = value!;
              });
            },
          ),
          DropdownButton<String>(
            value: _selectedTipo,
            items: ['Todos', 'Local', 'Domicilio', 'VIP']
                .map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedTipo = value!;
              });
            },
          ),
        ],
      ),
      drawer: MenuLateralMesero(),
      body: StreamBuilder<List<OrderModel>>(
        stream: _pedidoService.obtenerPedidosFiltrados(
            _selectedEstado, _selectedTipo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return Center(child: Text('No hay pedidos activos.'));
          }
          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
