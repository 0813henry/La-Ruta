import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/transaccion_model.dart';

class VentaItem extends StatelessWidget {
  final Transaction transaccion;

  const VentaItem({required this.transaccion, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.receipt, color: Theme.of(context).primaryColor),
        title: Text('Transacción: ${transaccion.title}'),
        subtitle: Text(
          'Fecha: ${transaccion.date.toLocal().toString().split(' ')[0]}\n'
          'Método de Pago: ${transaccion.paymentMethod}',
        ),
        trailing: Text(
          '\$${transaccion.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
