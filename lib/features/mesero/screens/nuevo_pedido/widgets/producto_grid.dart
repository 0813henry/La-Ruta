// ProductoGrid.dart
import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';

import 'producto_card.dart';

class ProductoGrid extends StatelessWidget {
  final String? selectedCategory;
  final void Function(Product product) onProductTap;

  const ProductoGrid({
    super.key,
    required this.selectedCategory,
    required this.onProductTap,
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
        return LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: isMobile ? 0.68 : 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductoCard(
                  product: product,
                  onTap: () => onProductTap(product),
                );
              },
            );
          },
        );
      },
    );
  }
}
