import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
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
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

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
            // Nombre del producto
            Text(
              product.name,
              style: TextStyle(
                fontSize: isWide ? 24 : 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Imagen
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl!,
                  height: isWide ? 220 : 160,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Descripción
            Text(
              product.descripcion,
              style: TextStyle(
                  fontSize: isWide ? 18 : 18, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Precio
            Text(
              '\$${product.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: isWide ? 19 : 19,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            // Stock
            Text(
              'Disponible: ${product.stock}',
              style: TextStyle(
                  fontSize: isWide ? 14 : 12, color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Selector de cantidad
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleButton(Icons.remove, () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                }),
                const SizedBox(width: 16),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                _buildCircleButton(Icons.add, () {
                  if (_quantity < product.stock) {
                    setState(() => _quantity++);
                  }
                }),
              ],
            ),

            const SizedBox(height: 20),

            // Comentario
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comentario (opcional)',
                floatingLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                labelStyle: const TextStyle(
                  color: AppColors.textSecondary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onChanged: (value) => _comment = value,
            ),
            const SizedBox(height: 20),

            // Botón de confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _quantity <= product.stock
                    ? () {
                        widget.onConfirm(_quantity, _comment);
                        Navigator.pop(context);
                      }
                    : null,
                icon: const Icon(
                  Icons.add_shopping_cart,
                  color: AppColors.white,
                ),
                label: const Text(
                  'Agregar al Pedido',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

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
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}
