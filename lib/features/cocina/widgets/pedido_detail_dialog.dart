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

  void _cambiarEstado(BuildContext context, String nuevoEstado) async {
    if (pedido.id == null || pedido.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: El ID del pedido no está disponible.')),
      );
      return;
    }
    try {
      if (onEstadoCambiado != null) {
        await Future.sync(() => onEstadoCambiado!(pedido.id!, nuevoEstado));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el estado: $e')),
      );
    }
  }

  double _divisionSubtotal(List<OrderItem> items) {
    double subtotal = 0.0;
    for (var item in items) {
      final adicionalesTotal = item.adicionales.fold(
        0.0,
        (sum, adicional) => sum + (adicional['price'] as double),
      );
      subtotal += (item.precio + adicionalesTotal) * item.cantidad;
    }
    return subtotal;
  }

  double _totalGeneral(OrderModel pedido) {
    double total = _divisionSubtotal(pedido.items);
    if (pedido.divisiones != null && pedido.divisiones!.isNotEmpty) {
      pedido.divisiones!.forEach((_, items) {
        total += _divisionSubtotal(items);
      });
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final divisiones = pedido.divisiones ?? {};
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
            Divider(),
            Text('Productos principales:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...pedido.items.map((item) {
              final adicionalesTotal = item.adicionales.fold(
                0.0,
                (sum, adicional) => sum + (adicional['price'] as double),
              );
              final itemTotal =
                  (item.precio + adicionalesTotal) * item.cantidad;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.nombre} x${item.cantidad}')),
                    Text('\$${itemTotal.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Subtotal: \$${_divisionSubtotal(pedido.items).toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (divisiones.isNotEmpty) ...[
              Divider(height: 24),
              Text('Divisiones:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...divisiones.entries.map((entry) {
                final division = entry.key;
                final productos = entry.value;
                final subtotal = _divisionSubtotal(productos);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: Colors.grey[100],
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('División: $division',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...productos.map((item) {
                            final adicionalesTotal = item.adicionales.fold(
                              0.0,
                              (sum, adicional) =>
                                  sum + (adicional['price'] as double),
                            );
                            final itemTotal = (item.precio + adicionalesTotal) *
                                item.cantidad;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          '${item.nombre} x${item.cantidad}')),
                                  Text('\$${itemTotal.toStringAsFixed(2)}'),
                                ],
                              ),
                            );
                          }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'TOTAL GENERAL: \$${_totalGeneral(pedido).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green[700],
                  ),
                ),
              ],
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
