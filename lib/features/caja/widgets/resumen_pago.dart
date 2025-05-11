import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';

class ResumenPago extends StatelessWidget {
  final OrderModel pedido;

  const ResumenPago({required this.pedido, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Pedido',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 8),
            Text('ID del Pedido: ${pedido.id}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Cliente: ${pedido.cliente}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Estado: ${pedido.estado}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Tipo: ${pedido.tipo}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Total: \$${pedido.total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Detalles:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            ...pedido.items.map((detalle) => Text(
                  '- ${detalle.nombre} x${detalle.cantidad} (\$${detalle.precio.toStringAsFixed(2)})\n  ${detalle.descripcion}',
                  style: TextStyle(fontSize: 14),
                )),
          ],
        ),
      ),
    );
  }
}
