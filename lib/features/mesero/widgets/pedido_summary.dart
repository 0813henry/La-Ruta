import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import '../../../core/model/pedido_model.dart';

class PedidoSummary extends StatelessWidget {
  final List<OrderItem> items;
  final double total;
  final VoidCallback onConfirm;

  const PedidoSummary({
    required this.items,
    required this.total,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return AlertDialog(
      title: Text(
        'Resumen del Pedido',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isWideScreen ? 2 : 3,
                        child: Text(
                          '${item.nombre} x${item.cantidad}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: isWideScreen ? 3 : 2,
                        child: Text(
                          'Notas: ${item.descripcion.isNotEmpty ? item.descripcion : "Ninguna"}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Text(
                        '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                )),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Confirmar Pedido'),
        ),
      ],
    );
  }
}
