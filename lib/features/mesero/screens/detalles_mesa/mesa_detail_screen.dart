import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import '../../../../routes/app_routes.dart';

class MesaDetailScreen extends StatefulWidget {
  final String mesaId; // ID generado por Firebase (no se mostrará)
  final String nombre; // Nombre de la mesa o cliente
  final String cliente; // Nombre completo del cliente
  final int numero; // Número de la mesa (visible en el título)

  const MesaDetailScreen({
    required this.mesaId,
    required this.nombre,
    required this.cliente,
    required this.numero, // Número de la mesa
    super.key,
  });

  @override
  _MesaDetailScreenState createState() => _MesaDetailScreenState();
}

class _MesaDetailScreenState extends State<MesaDetailScreen> {
  final PedidoService _pedidoService = PedidoService();

  Future<void> _dividirCuenta() async {
    final productos =
        await _pedidoService.obtenerProductosPorMesa(widget.mesaId);
    if (productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay productos para dividir.')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.dividirCuenta,
      arguments: {'mesaId': widget.mesaId, 'productos': productos},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Detalles de la Mesa: #${widget.numero}'), // Actualizamos el título
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              'Mesa: ${widget.nombre}', // Mostrar el nombre de la mesa (cliente)
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: Icon(
              Icons.person,
              color: Colors.blue,
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Tomar Pedido'),
            leading: Icon(Icons.restaurant_menu),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.nuevoPedido,
                arguments: {
                  'mesaId': widget.mesaId,
                  'nombre': widget.nombre,
                  'numero': widget.numero,
                },
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Dividir Cuenta'),
            leading: Icon(Icons.call_split),
            onTap: _dividirCuenta,
          ),
        ],
      ),
    );
  }
}
