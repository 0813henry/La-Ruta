import 'package:flutter/material.dart';
import '../../../core/model/pedido_model.dart';

class CarritoWidget extends StatelessWidget {
  final List<OrderItem> cartItems;
  final Function(OrderItem) onEditItem;
  final Function(OrderItem) onRemoveItem;
  final double total;
  final VoidCallback onConfirmOrder;
  final VoidCallback onCloseMesa; // Nueva opción para cerrar la mesa

  const CarritoWidget({
    required this.cartItems,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.total,
    required this.onConfirmOrder,
    required this.onCloseMesa, // Nueva opción
    Key? key,
  }) : super(key: key);

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
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('${item.nombre} x${item.cantidad}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Comentario: ${item.descripcion.isNotEmpty ? item.descripcion : "Ninguno"}'),
                    Text('Precio: \$${item.precio.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: Text(
                  '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                onTap: () => onEditItem(item),
              ),
            );
          }).toList(),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Total: \$${total.toStringAsFixed(2)}',
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
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onCloseMesa,
            icon: Icon(Icons.close),
            label: Text('Cerrar Mesa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
