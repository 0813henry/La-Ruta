import 'package:flutter/material.dart';
import '../../../core/model/pedido_model.dart';
import '../../../core/services/pedido_service.dart';

class DividirCuentaScreen extends StatefulWidget {
  final String mesaId;
  final List<OrderItem> productos;

  const DividirCuentaScreen(
      {required this.mesaId, required this.productos, Key? key})
      : super(key: key);

  @override
  _DividirCuentaScreenState createState() => _DividirCuentaScreenState();
}

class _DividirCuentaScreenState extends State<DividirCuentaScreen> {
  final PedidoService _pedidoService = PedidoService();
  final Map<String, List<OrderItem>> _mesasDivididas = {};

  void _moverProducto(String mesaDestino, OrderItem producto) {
    setState(() {
      _mesasDivididas.putIfAbsent(mesaDestino, () => []).add(producto);
      widget.productos.remove(producto);
    });
  }

  Future<void> _guardarDivision() async {
    for (var entry in _mesasDivididas.entries) {
      await _pedidoService.crearPedido(OrderModel(
        cliente: 'Mesa ${entry.key}',
        items: entry.value,
        total: entry.value
            .fold(0.0, (sum, item) => sum + item.precio * item.cantidad),
        estado: 'Pendiente',
        tipo: 'Local',
        startTime: DateTime.now(),
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cuenta dividida exitosamente')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dividir Cuenta')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.productos.length,
              itemBuilder: (context, index) {
                final producto = widget.productos[index];
                return ListTile(
                  title: Text('${producto.nombre} x${producto.cantidad}'),
                  subtitle: Text(
                      '\$${(producto.precio * producto.cantidad).toStringAsFixed(2)}'),
                  trailing: DropdownButton<String>(
                    hint: Text('Mover a'),
                    items: _mesasDivididas.keys
                        .map((mesa) => DropdownMenuItem(
                              value: mesa,
                              child: Text(mesa),
                            ))
                        .toList(),
                    onChanged: (mesaDestino) {
                      if (mesaDestino != null) {
                        _moverProducto(mesaDestino, producto);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _guardarDivision,
            child: Text('Guardar División'),
          ),
        ],
      ),
    );
  }
}
