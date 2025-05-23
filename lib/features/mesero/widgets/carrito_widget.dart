import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/widgets/wbutton.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/model/producto_model.dart';

class CarritoWidget extends StatefulWidget {
  final List<OrderItem> cartItems;
  final Future<void> Function(OrderItem) onEditItem;
  final Function(OrderItem) onRemoveItem;
  final double total;
  final VoidCallback onConfirmOrder;
  final String confirmButtonText;
  final Map<String, List<OrderItem>>? divisiones;

  /// ✅ Nuevo: Mapa con los productos disponibles (usado solo para mostrar imágenes)
  final Map<String, Product> productosDisponibles;

  const CarritoWidget({
    super.key,
    required this.cartItems,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.total,
    required this.onConfirmOrder,
    required this.productosDisponibles,
    this.confirmButtonText = 'Confirmar Pedido',
    this.divisiones,
  });

  @override
  State<CarritoWidget> createState() => _CarritoWidgetState();
}

class _CarritoWidgetState extends State<CarritoWidget> {
  Future<void> _editarItem(OrderItem item) async {
    await widget.onEditItem(item);
    setState(() {});
  }

  double _calcularTotal(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) {
      final adicionalesTotal = item.adicionales.fold(
        0.0,
        (s, adicional) => s + (adicional['price'] as double),
      );
      return sum + (item.precio + adicionalesTotal) * item.cantidad;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalDivisiones = _calcularTotal(
        widget.divisiones?.values.expand((e) => e).toList() ?? []);
    final totalGeneral = _calcularTotal(widget.cartItems) + totalDivisiones;

    return Container(
      padding: const EdgeInsets.all(16)
          .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Carrito (${widget.cartItems.length} productos)',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ...widget.cartItems.map((item) => _buildItemCard(item)),
              if (widget.divisiones != null &&
                  widget.divisiones!.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Divisiones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...widget.divisiones!.entries.map((entry) {
                  final division = entry.key;
                  final items = entry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ExpansionTile(
                      title: Text(
                        'División: $division',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children:
                          items.map((item) => _buildItemCard(item)).toList(),
                    ),
                  );
                }),
              ],
              const Divider(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: \$${totalGeneral.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: WButton(
                  onPressed: widget.onConfirmOrder,
                  label: widget.confirmButtonText,
                  icon: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(OrderItem item) {
    final adicionalesTotal = item.adicionales.fold(
      0.0,
      (sum, ad) => sum + (ad['price'] as double),
    );
    final itemTotal = (item.precio + adicionalesTotal) * item.cantidad;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final product = widget.productosDisponibles[item.idProducto];
    final imageUrl = product?.imageUrl;

    return Card(
      elevation: 1,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: isPortrait ? 80 : 100,
                      height: isPortrait ? 80 : 100,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(width: 16),

            // Detalles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.nombre} x${item.cantidad}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  if (item.descripcion.isNotEmpty)
                    Text(
                      'Comentario: ${item.descripcion}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  Text(
                    'Precio base: \$${item.precio.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (item.adicionales.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    const Text(
                      'Adicionales:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    ...item.adicionales.map((ad) => Text(
                          '${ad['name']} - \$${(ad['price'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.grey),
                        )),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal: \$${itemTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editarItem(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
