import 'package:flutter/material.dart';
import '../../../core/model/pedido_model.dart';

class CarritoWidget extends StatelessWidget {
  final List<OrderItem> cartItems;
  final Function(OrderItem) onEditItem;
  final Function(OrderItem) onRemoveItem;
  final double total;
  final VoidCallback onConfirmOrder;

  const CarritoWidget({
    required this.cartItems,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.total,
    required this.onConfirmOrder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Carrito (${cartItems.length} productos)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...cartItems.map((item) {
            final adicionalesTotal = item.adicionales.fold(
              0.0,
              (sum, adicional) => sum + (adicional['price'] as double),
            );
            final itemTotal = (item.precio + adicionalesTotal) * item.cantidad;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12.0),
                title: Text(
                  '${item.nombre} x${item.cantidad}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.descripcion.isNotEmpty)
                      Text(
                        'Comentario: ${item.descripcion}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    Text(
                      'Precio base: \$${item.precio.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    if (item.adicionales.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adicionales:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                          ...item.adicionales.map((ad) => Text(
                                '${ad['name']} - \$${(ad['price'] as double).toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey[600]),
                              )),
                        ],
                      ),
                    SizedBox(height: 4),
                    Text(
                      'Subtotal: \$${itemTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEditItem(item),
                ),
              ),
            );
          }),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Total: \$${cartItems.fold(0.0, (sum, item) {
                final adicionalesTotal = item.adicionales.fold(
                  0.0,
                  (sum, adicional) => sum + (adicional['price'] as double),
                );
                return sum + (item.precio + adicionalesTotal) * item.cantidad;
              }).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onConfirmOrder,
            icon: Icon(Icons.check),
            label: Text('Confirmar Pedido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
