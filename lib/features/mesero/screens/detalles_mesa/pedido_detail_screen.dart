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
          pedido: widget.pedido,
          mesaId:
              widget.pedido.id ?? '', // Pasa el id de la mesa/pedido si existe
          productos: List<OrderItem>.from(_items),
        ),
      ),
    );
  }

  double _divisionSubtotal(List<OrderItem> items) {
    double subtotal = 0.0;
    for (var item in items) {
      final adicionalesTotal = item.adicionales.fold(
        0.0,
        (sum, adicional) => sum + (adicional['price'] as double),
      );
      subtotal += (item.precio + adicionalesTotal) * item.cantidad;
    }
    return subtotal;
  }

  double _totalGeneral() {
    double total = _divisionSubtotal(_items);
    if (widget.pedido.divisiones != null &&
        widget.pedido.divisiones!.isNotEmpty) {
      widget.pedido.divisiones!.forEach((_, items) {
        total += _divisionSubtotal(items);
      });
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final divisiones = widget.pedido.divisiones ?? {};
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
            child: SingleChildScrollView(
              child: Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Factura',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      SizedBox(height: 8),
                      Text('Cliente: ${widget.pedido.cliente}',
                          style: TextStyle(fontSize: 16)),
                      Text('Estado: ${widget.pedido.estado}',
                          style: TextStyle(fontSize: 16)),
                      Text('Tipo: ${widget.pedido.tipo}',
                          style: TextStyle(fontSize: 16)),
                      Divider(height: 24),
                      Text('Productos principales:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      ..._items.map((item) {
                        final adicionalesTotal = item.adicionales.fold(
                          0.0,
                          (sum, adicional) =>
                              sum + (adicional['price'] as double),
                        );
                        final itemTotal =
                            (item.precio + adicionalesTotal) * item.cantidad;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child:
                                      Text('${item.nombre} x${item.cantidad}')),
                              Text('\$${itemTotal.toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Subtotal: \$${_divisionSubtotal(_items).toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (divisiones.isNotEmpty) ...[
                        Divider(height: 24),
                        Text('Divisiones:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        ...divisiones.entries.map((entry) {
                          final division = entry.key;
                          final productos = entry.value;
                          final subtotal = _divisionSubtotal(productos);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              color: Colors.grey[100],
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('División: $division',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    ...productos.map((item) {
                                      final adicionalesTotal =
                                          item.adicionales.fold(
                                        0.0,
                                        (sum, adicional) =>
                                            sum +
                                            (adicional['price'] as double),
                                      );
                                      final itemTotal =
                                          (item.precio + adicionalesTotal) *
                                              item.cantidad;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                                    '${item.nombre} x${item.cantidad}')),
                                            Text(
                                                '\$${itemTotal.toStringAsFixed(2)}'),
                                          ],
                                        ),
                                      );
                                    }),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                      Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'TOTAL GENERAL: \$${_totalGeneral().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
