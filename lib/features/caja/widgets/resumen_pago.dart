import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';

class ResumenPago extends StatelessWidget {
  final OrderModel pedido;

  const ResumenPago({required this.pedido, super.key});

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

  double _totalGeneral() {
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
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Factura',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Divider(thickness: 1, color: Colors.grey[300]),
              SizedBox(height: 8),
              Text('ID del Pedido: ${pedido.id}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text('Cliente: ${pedido.cliente}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text('Estado: ${pedido.estado}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text('Tipo: ${pedido.tipo}', style: TextStyle(fontSize: 16)),
              Divider(height: 24),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                              final itemTotal =
                                  (item.precio + adicionalesTotal) *
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
                    'TOTAL GENERAL: \$${_totalGeneral().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
