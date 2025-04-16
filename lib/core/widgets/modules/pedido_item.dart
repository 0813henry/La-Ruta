import 'package:flutter/material.dart';
import '../../../core/model/pedido_model.dart';

class PedidoItem extends StatelessWidget {
  final OrderModel pedido;
  final VoidCallback onTap;

  const PedidoItem({
    required this.pedido,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Mesa: ${pedido.cliente}'),
      subtitle: Text('Estado: ${pedido.estado}'),
      trailing: Text('\$${pedido.total.toStringAsFixed(2)}'),
      onTap: onTap,
    );
  }
}
