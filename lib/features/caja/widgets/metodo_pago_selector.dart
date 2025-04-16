import 'package:flutter/material.dart';

class MetodoPagoSelector extends StatelessWidget {
  final String metodoSeleccionado;
  final Function(String) onMetodoSeleccionado;

  const MetodoPagoSelector({
    required this.metodoSeleccionado,
    required this.onMetodoSeleccionado,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metodosPago = ['Efectivo', 'Tarjeta', 'Transferencia'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Pago:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: metodosPago.map((metodo) {
            return ChoiceChip(
              label: Text(metodo),
              selected: metodoSeleccionado == metodo,
              onSelected: (selected) {
                if (selected) {
                  onMetodoSeleccionado(metodo);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
