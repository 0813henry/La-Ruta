import 'package:flutter/material.dart';

class PedidoKitchenCard extends StatelessWidget {
  final String pedidoId;
  final String cliente;
  final String estado;
  final Function()? onActionPressed;

  PedidoKitchenCard({
    required this.pedidoId,
    required this.cliente,
    required this.estado,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Pedido $pedidoId'),
        subtitle: Text('Cliente: $cliente\nEstado: $estado'),
        trailing: onActionPressed != null
            ? IconButton(
                icon: Icon(Icons.check),
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }
}
