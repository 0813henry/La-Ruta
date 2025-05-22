import 'package:flutter/material.dart';

class DialogConfirmarPedido extends StatelessWidget {
  final String nombre;
  final String? clienteInicial;
  final String? tipoInicial;

  const DialogConfirmarPedido({
    super.key,
    required this.nombre,
    this.clienteInicial,
    this.tipoInicial,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController clienteController =
        TextEditingController(text: clienteInicial ?? nombre);
    String selectedTipo = tipoInicial ?? 'Local';
    final tipos = ['Local', 'Domicilio', 'VIP'];

    return AlertDialog(
      title: const Text('Datos del Cliente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: clienteController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Cliente',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedTipo,
            items: tipos
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) {
              if (value != null) selectedTipo = value;
            },
            decoration: const InputDecoration(
              labelText: 'Tipo de Pedido',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'cliente': clienteController.text.trim(),
              'tipo': selectedTipo,
            });
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
