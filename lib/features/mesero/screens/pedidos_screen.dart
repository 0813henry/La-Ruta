import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/widgets/modules/pedido_item.dart';
import 'package:restaurante_app/features/mesero/screens/nuevo_pedido/nuevo_pedido_screen.dart';
import '../widgets/menu_lateral_mesero.dart';
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final PedidoService _pedidoService = PedidoService();
  String _selectedEstado = 'Todos'; // Filtro por estado
  String _selectedTipo = 'Todos'; // Filtro por tipo
  String _searchQuery = ''; // Búsqueda por cliente

  @override
  void initState() {
    super.initState();
    NotificationService().escucharNotificacionesCocina((pedidoId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El pedido $pedidoId está listo.')),
      );
    });
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por cliente o mesa',
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget buildTipoDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<String>(
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
        isExpanded: true,
      ),
    );
  }

  Widget buildEstadoDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<String>(
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
        isExpanded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos Activos'),
      ),
      drawer: MenuLateralMesero(),
      body: Column(
        children: [
          buildSearchBar(),
          Row(
            children: [
              Expanded(child: buildEstadoDropdown()),
              Expanded(child: buildTipoDropdown()),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
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
                final filteredPedidos = pedidos
                    .where((pedido) =>
                        pedido.cliente.toLowerCase().contains(_searchQuery))
                    .toList();
                if (filteredPedidos.isEmpty) {
                  return Center(child: Text('No hay pedidos activos.'));
                }
                return ListView.builder(
                  itemCount: filteredPedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = filteredPedidos[index];
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Nuevo Pedido'),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NuevoPedidoScreen(
                mesaId: 'mesa_demo', // Reemplaza con el ID real de la mesa
                nombre: 'Mesa Demo', // Reemplaza con el nombre real de la mesa
              ),
            ),
          );
        },
      ),
    );
  }
}
