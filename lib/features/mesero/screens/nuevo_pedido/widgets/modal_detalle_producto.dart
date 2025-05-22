import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/producto_model.dart';

class ModalDetalleProducto extends StatefulWidget {
  final Product product;
  final void Function(int quantity, String comment) onConfirm;

  const ModalDetalleProducto({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  State<ModalDetalleProducto> createState() => _ModalDetalleProductoState();
}

class _ModalDetalleProductoState extends State<ModalDetalleProducto> {
  int _quantity = 1;
  String _comment = '';
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isWide = MediaQuery.of(context).size.width > 600;

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
            Text(
              product.name,
              style: TextStyle(
                  fontSize: isWide ? 24 : 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              Image.network(
                product.imageUrl!,
                height: isWide ? 200 : 150,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 8),
            Text(
              product.descripcion,
              style: TextStyle(fontSize: isWide ? 18 : 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Precio: \$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: isWide ? 18 : 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Stock disponible: ${product.stock}',
              style: TextStyle(
                  fontSize: isWide ? 16 : 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _quantity < product.stock
                      ? () => setState(() => _quantity++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _comment = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _quantity <= product.stock
                  ? () {
                      widget.onConfirm(_quantity, _comment);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Agregar al Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
