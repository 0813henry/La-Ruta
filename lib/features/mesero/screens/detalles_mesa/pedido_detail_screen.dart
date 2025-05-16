import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/features/mesero/screens/detalles_mesa/dividir_cuenta_screen.dart';

class PedidoDetailScreen extends StatefulWidget {
  final OrderModel pedido;

  const PedidoDetailScreen({required this.pedido, super.key});

  @override
  State<PedidoDetailScreen> createState() => _PedidoDetailScreenState();
}

class _PedidoDetailScreenState extends State<PedidoDetailScreen> {
  late List<OrderItem> _items;
  late double _total;
  final PedidoService _pedidoService = PedidoService();

  @override
  void initState() {
    super.initState();
    _items = List<OrderItem>.from(widget.pedido.items);
    _total = _items.fold(0.0, (sum, item) => sum + item.precio * item.cantidad);
  }

  void _actualizarCantidad(OrderItem item, int nuevaCantidad) {
    setState(() {
      item.cantidad = nuevaCantidad;
      _total = _items.fold(0.0, (sum, i) => sum + i.precio * i.cantidad);
    });
  }

  void _eliminarProducto(OrderItem item) {
    setState(() {
      _items.remove(item);
      _total = _items.fold(0.0, (sum, i) => sum + i.precio * i.cantidad);
    });
  }

  Future<void> _guardarCambios() async {
    final pedidoActualizado = widget.pedido.copyWith(
      items: _items,
      total: _total,
    );
    await _pedidoService.actualizarPedido(pedidoActualizado);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pedido actualizado')),
    );
    Navigator.pop(context, pedidoActualizado);
  }

  void _dividirCuenta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DividirCuentaScreen(
          mesaId:
              widget.pedido.id ?? '', // Pasa el id de la mesa/pedido si existe
          productos: List<OrderItem>.from(_items),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Pedido'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _guardarCambios,
            tooltip: 'Guardar Cambios',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item.nombre),
                  subtitle: Text('\$${item.precio.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: item.cantidad > 1
                            ? () => _actualizarCantidad(item, item.cantidad - 1)
                            : null,
                      ),
                      Text('${item.cantidad}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () =>
                            _actualizarCantidad(item, item.cantidad + 1),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarProducto(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('\$${_total.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: ElevatedButton.icon(
              icon: Icon(Icons.call_split),
              label: Text('Dividir Cuenta'),
              onPressed: _items.isNotEmpty ? _dividirCuenta : null,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
