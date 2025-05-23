import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/widgets/wbutton.dart';
import 'package:restaurante_app/features/mesero/screens/detalles_mesa/dividir_cuenta_screen.dart';
import 'package:restaurante_app/core/utils/pdf_generator.dart'; // <-- Importa el generador de PDF

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
          mesaId: widget.pedido.id, // Pasa el id de la mesa/pedido si existe
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

  Future<void> _guardarComoPDF() async {
    await generarPDFPedido(widget.pedido);
  }

  @override
  Widget build(BuildContext context) {
    final divisiones = widget.pedido.divisiones ?? {};
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          'Detalle del Pedido',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _guardarComoPDF,
            tooltip: 'Guardar como PDF',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Factura',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: AppColors.textPrimary)),
                          Divider(),
                          RichText(
                            text: TextSpan(
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                              children: [
                                TextSpan(
                                    text: 'Cliente: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                                TextSpan(
                                    text: widget.pedido.cliente,
                                    style: TextStyle(
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                              children: [
                                TextSpan(
                                    text: 'Estado: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: widget.pedido.estado),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                              children: [
                                TextSpan(
                                    text: 'Tipo: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: widget.pedido.tipo),
                              ],
                            ),
                          ),
                          Divider(height: 24),
                          Text('Orden de la Mesa:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          ..._items.map((item) {
                            final adicionalesTotal = item.adicionales.fold(
                              0.0,
                              (sum, adicional) =>
                                  sum + (adicional['price'] as double),
                            );
                            final itemTotal = (item.precio + adicionalesTotal) *
                                item.cantidad;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    '  - ${item.nombre} x${item.cantidad}',
                                    style: TextStyle(fontSize: 15),
                                  )),
                                  Text('\$${itemTotal.toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 15)),
                                ],
                              ),
                            );
                          }).toList(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Subtotal: \$${_divisionSubtotal(_items).toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                          if (divisiones.isNotEmpty) ...[
                            Divider(height: 12),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    '\$${itemTotal.toStringAsFixed(0)}'),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Subtotal: \$${subtotal.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                          Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  children: [
                                    TextSpan(
                                        text: 'TOTAL GENERAL: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text:
                                            _totalGeneral().toStringAsFixed(0)),
                                  ],
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WButton(
                      label: 'Dividir Cuenta',
                      icon: Icon(Icons.call_split, color: AppColors.white),
                      onPressed: _items.isNotEmpty ? _dividirCuenta : null),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
