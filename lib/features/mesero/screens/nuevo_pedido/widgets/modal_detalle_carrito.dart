import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';

class ModalDetalleCarrito extends StatefulWidget {
  final OrderItem item;
  final void Function(OrderItem item, int cantidad, String comentario) onUpdate;
  final void Function(OrderItem item) onDelete;

  const ModalDetalleCarrito({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ModalDetalleCarrito> createState() => _ModalDetalleCarritoState();
}

class _ModalDetalleCarritoState extends State<ModalDetalleCarrito> {
  late TextEditingController _cantidadController;
  late TextEditingController _comentarioController;

  @override
  void initState() {
    super.initState();
    _cantidadController =
        TextEditingController(text: widget.item.cantidad.toString());
    _comentarioController =
        TextEditingController(text: widget.item.descripcion);
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.nombre,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    final current =
                        int.tryParse(_cantidadController.text) ?? item.cantidad;
                    if (current > 1) {
                      setState(() {
                        _cantidadController.text = '${current - 1}';
                      });
                    }
                  },
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _cantidadController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      final current = int.tryParse(_cantidadController.text) ??
                          item.cantidad;
                      _cantidadController.text = '${current + 1}';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final cantidad =
                    int.tryParse(_cantidadController.text) ?? item.cantidad;
                final comentario = _comentarioController.text;
                widget.onUpdate(item, cantidad, comentario);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.update),
              label: const Text('Actualizar'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.onDelete(item);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }
}
