import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/widgets/wbutton.dart';
import 'package:restaurante_app/core/widgets/wtext_field.dart';

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
            const SizedBox(height: 16),

            // Contador con diseño visual moderno
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleButton(Icons.remove, () {
                  final current =
                      int.tryParse(_cantidadController.text) ?? item.cantidad;
                  if (current > 1) {
                    setState(() {
                      _cantidadController.text = '${current - 1}';
                    });
                  }
                }),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    _cantidadController.text,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                _buildCircleButton(Icons.add, () {
                  final current =
                      int.tryParse(_cantidadController.text) ?? item.cantidad;
                  setState(() {
                    _cantidadController.text = '${current + 1}';
                  });
                }),
              ],
            ),

            const SizedBox(height: 20),

            // // Comentario
            // TextField(
            //   controller: _comentarioController,
            //   decoration: const InputDecoration(
            //     labelText: 'Comentario (opcional)',
            //     border: OutlineInputBorder(),
            //   ),
            // ),
            WTextField(
              controller: _comentarioController,
              label: 'Comentario (opcional)',
            ),

            const SizedBox(height: 20),

            // Botón actualizar + eliminar alineado correctamente
            Row(
              children: [
                Expanded(
                  child: WButton(
                    onPressed: () {
                      final cantidad = int.tryParse(_cantidadController.text) ??
                          item.cantidad;
                      final comentario = _comentarioController.text;
                      widget.onUpdate(item, cantidad, comentario);
                      Navigator.pop(context);
                    },
                    label: 'Actualizar',
                    icon:
                        const Icon(Icons.check, size: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: AppColors.secondary, size: 35),
                  onPressed: () {
                    widget.onDelete(item);
                    Navigator.pop(context);
                  },
                  tooltip: "Eliminar",
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Botón circular reutilizable
  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.white),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}
