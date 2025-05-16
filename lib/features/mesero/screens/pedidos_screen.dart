import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/widgets/modules/pedido_item.dart';
import 'package:restaurante_app/features/cocina/screens/pedido_detail_screen.dart';
import 'package:restaurante_app/features/mesero/screens/detalles_mesa/dividir_cuenta_screen.dart';
import 'package:restaurante_app/features/mesero/screens/nuevo_pedido/nuevo_pedido_screen.dart';
import 'package:restaurante_app/core/constants/app_colors.dart'; // <-- Importa AppColors
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
      if (!mounted) return; // <-- Solución: solo usar context si está montado
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

  // Mapeo de colores para tipos de pedido
  Color _colorTipoPedido(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'domicilio':
        return AppColors.domicilio;
      case 'vip':
        return AppColors.vip;
      case 'local':
        return AppColors.principal;
      default:
        return AppColors.coolGray;
    }
  }

  // Mapeo de colores para estados de pedido
  Color _colorEstadoPedido(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return AppColors.pendiente;
      case 'en proceso':
        return AppColors.enProceso;
      case 'listo':
        return AppColors.listoParaServir;
      case 'en camino':
        return AppColors.enCamino;
      case 'entregado':
        return AppColors.entregado;
      case 'cancelado':
        return AppColors.cancelado;
      default:
        return AppColors.coolGray;
    }
  }

  Widget buildTipoDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<String>(
        value: _selectedTipo,
        items: [
          {'label': 'Todos', 'color': AppColors.coolGray},
          {'label': 'Local', 'color': AppColors.principal},
          {'label': 'Domicilio', 'color': AppColors.domicilio},
          {'label': 'VIP', 'color': AppColors.vip},
        ]
            .map((tipo) => DropdownMenuItem(
                  value: tipo['label'] as String,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: tipo['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(tipo['label'] as String),
                    ],
                  ),
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
          {'label': 'Todos', 'color': AppColors.coolGray},
          {'label': 'Pendiente', 'color': AppColors.pendiente},
          {'label': 'En Proceso', 'color': AppColors.enProceso},
          {'label': 'Listo', 'color': AppColors.listoParaServir},
        ]
            .map((estado) => DropdownMenuItem(
                  value: estado['label'] as String,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: estado['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(estado['label'] as String),
                    ],
                  ),
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
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _colorTipoPedido(pedido.tipo),
                          child: Icon(Icons.fastfood, color: Colors.white),
                        ),
                        title: Text(pedido.cliente),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _colorEstadoPedido(pedido.estado),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    pedido.estado,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(pedido.tipo),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Total: \$${(() {
                                double total = pedido.total;
                                if (pedido.divisiones != null &&
                                    pedido.divisiones!.isNotEmpty) {
                                  double totalDiv = 0.0;
                                  pedido.divisiones!.forEach((_, items) {
                                    for (var item in items) {
                                      final adicionalesTotal =
                                          item.adicionales.fold(
                                        0.0,
                                        (sum, adicional) =>
                                            sum +
                                            (adicional['price'] as double),
                                      );
                                      totalDiv +=
                                          (item.precio + adicionalesTotal) *
                                              item.cantidad;
                                    }
                                  });
                                  total += totalDiv;
                                }
                                return total.toStringAsFixed(2);
                              })()}',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NuevoPedidoScreen(
                                      mesaId: pedido.id ?? 'mesa_demo',
                                      nombre: pedido.cliente,
                                      pedido: pedido,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.call_split, color: Colors.green),
                              tooltip: 'Dividir Cuenta',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DividirCuentaScreen(
                                      mesaId: pedido.id ?? '',
                                      productos:
                                          List<OrderItem>.from(pedido.items),
                                      pedido: pedido,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PedidoDetailScreen(pedido: pedido),
                            ),
                          );
                        },
                      ),
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
