import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';

class PedidoDetailDialog extends StatelessWidget {
  final OrderModel pedido;
  final Function(String, String)? onEstadoCambiado;

  const PedidoDetailDialog({
    required this.pedido,
    this.onEstadoCambiado,
    super.key,
  });

  void _cambiarEstado(BuildContext context, String nuevoEstado) {
    if (pedido.id == null || pedido.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: El ID del pedido no está disponible.')),
      );
      return;
    }
    if (onEstadoCambiado != null) {
      onEstadoCambiado!(pedido.id!, nuevoEstado);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Detalles del Pedido ${pedido.id}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${pedido.cliente}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Estado: ${pedido.estado}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...pedido.items.map((item) => ListTile(
                  title: Text('${item.nombre} x${item.cantidad}'),
                  subtitle: Text('Notas: ${item.descripcion}'),
                  trailing: Text(
                    '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                  ),
                )),
            Divider(),
            Text(
              'Total: \$${pedido.total.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cerrar'),
        ),
        if (pedido.estado == 'Pendiente')
          ElevatedButton(
            onPressed: () => _cambiarEstado(context, 'En Proceso'),
            child: Text('Marcar En Proceso'),
          ),
        if (pedido.estado == 'En Proceso')
          ElevatedButton(
            onPressed: () => _cambiarEstado(context, 'Listo'),
            child: Text('Marcar Listo'),
          ),
      ],
    );
  }
}
