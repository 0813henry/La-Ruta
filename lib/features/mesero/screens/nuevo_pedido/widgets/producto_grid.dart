// ✅ producto_grid.dart con stock actualizado dinámicamente
import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'producto_card.dart';

class ProductoGrid extends StatelessWidget {
  final String? selectedCategory;
  final void Function(Product product) onProductTap;
  final List<OrderItem> cartItems;

  const ProductoGrid({
    super.key,
    required this.selectedCategory,
    required this.onProductTap,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isMobile = size.width < 600;
    final crossAxisCount = isPortrait ? (isMobile ? 2 : 3) : (isMobile ? 3 : 4);

    return StreamBuilder<List<Product>>(
      stream: FirebaseService().getFilteredProductsStream(selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay productos disponibles.'));
        }

        final products = snapshot.data!;

        final updatedProducts = products.map((product) {
          final cartQuantity = cartItems
              .where((item) => item.idProducto == product.id)
              .fold<int>(0, (sum, item) => sum + (item.cantidad));
          return product.copyWith(stock: product.stock - cartQuantity);
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: isMobile ? 0.68 : 0.75,
          ),
          itemCount: updatedProducts.length,
          itemBuilder: (context, index) {
            final product = updatedProducts[index];
            return ProductoCard(
              product: product,
              onTap: () => onProductTap(product),
            );
          },
        );
      },
    );
  }
}
