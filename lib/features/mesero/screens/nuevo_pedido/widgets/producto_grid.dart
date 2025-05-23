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
    final width = size.width;
    int crossAxisCount = 2;

    if (width <= 370) {
      crossAxisCount = 1;
    } else if (width <= 399) {
      crossAxisCount = 1;
    } else if (width <= 554) {
      crossAxisCount = 2;
    } else if (width <= 593) {
      crossAxisCount = 2;
    } else if (width <= 600) {
      crossAxisCount = 3;
    } else if (width <= 628) {
      crossAxisCount = 2;
    } else if (width <= 849) {
      crossAxisCount = 3;
    } else if (width <= 999) {
      crossAxisCount = 4;
    } else if (width <= 1052) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 5;
    }

    final aspectRatio = width < 400
        ? 0.75
        : width < 600
            ? 0.7
            : width < 900
                ? 0.68
                : 0.65;

    return StreamBuilder<List<Product>>(
      stream: FirebaseService().getFilteredProductsStream(selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay productos disponibles.'));
        }

        final products = snapshot.data!;

        final updatedProducts = products.map((product) {
          final cartQuantity = cartItems
              .where((item) => item.idProducto == product.id)
              .fold<int>(0, (sum, item) => sum + item.cantidad);
          return product.copyWith(stock: product.stock - cartQuantity);
        }).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemCount: updatedProducts.length,
            itemBuilder: (context, index) {
              final product = updatedProducts[index];
              return ProductoCard(
                product: product,
                onTap: () => onProductTap(product),
              );
            },
          ),
        );
      },
    );
  }
}
