import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/features/mesero/widgets/carrito_widget.dart';

class ModalDetalleCarritoSheet extends StatelessWidget {
  final List<OrderItem> cart;
  final double total;
  final VoidCallback onConfirm;
  final void Function(OrderItem) onEditItem;
  final void Function(OrderItem) onRemoveItem;
  final Map<String, List<OrderItem>>? divisiones;
  final String confirmButtonText;

  const ModalDetalleCarritoSheet({
    super.key,
    required this.cart,
    required this.total,
    required this.onConfirm,
    required this.onEditItem,
    required this.onRemoveItem,
    this.divisiones,
    required this.confirmButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        children: [
          CarritoWidget(
            cartItems: cart,
            onEditItem: onEditItem,
            onRemoveItem: onRemoveItem,
            total: total,
            onConfirmOrder: onConfirm,
            confirmButtonText: confirmButtonText,
            divisiones: divisiones,
          ),
          if (divisiones != null && divisiones!.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView(
                  children: divisiones!.entries.map((entry) {
                    final division = entry.key;
                    final productos = entry.value;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpansionTile(
                        title: Text(
                          'División: $division',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        children: productos.map((producto) {
                          final adicionalesTotal = producto.adicionales.fold(
                            0.0,
                            (sum, adicional) =>
                                sum + (adicional['price'] as double),
                          );
                          final itemTotal =
                              (producto.precio + adicionalesTotal) *
                                  producto.cantidad;
                          return ListTile(
                            title: Text(
                                '${producto.nombre} x${producto.cantidad}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (producto.descripcion.isNotEmpty)
                                  Text(
                                    'Comentario: ${producto.descripcion}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                Text(
                                  'Precio base: \$${producto.precio.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                if (producto.adicionales.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Adicionales:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      ...producto.adicionales.map((ad) => Text(
                                            '${ad['name']} - \$${(ad['price'] as double).toStringAsFixed(2)}',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          )),
                                    ],
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subtotal: \$${itemTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
