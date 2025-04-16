import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';

class ResumenPago extends StatelessWidget {
  final OrderModel pedido;

  const ResumenPago({required this.pedido, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('ID del Pedido: ${pedido.id}'),
            Text('Total: \$${pedido.total.toStringAsFixed(2)}'),
            Text('Estado: ${pedido.estado}'),
          ],
        ),
      ),
    );
  }
}
