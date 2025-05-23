import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/producto_model.dart';

class ProductoCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductoCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double imageHeight;
    double fontSize;
    double padding;
    double buttonPadding;

    if (width < 370) {
      imageHeight = 100;
      fontSize = 13;
      padding = 6;
      buttonPadding = 8;
    } else if (width < 600) {
      imageHeight = 120;
      fontSize = 14;
      padding = 8;
      buttonPadding = 10;
    } else if (width < 850) {
      imageHeight = 140;
      fontSize = 15;
      padding = 10;
      buttonPadding = 12;
    } else if (width < 1000) {
      imageHeight = 160;
      fontSize = 16;
      padding = 12;
      buttonPadding = 14;
    } else if (width < 1100) {
      // ✅ NUEVO bloque para pantallas ~1024px
      imageHeight = 190;
      fontSize = 24;
      padding = 16;
      buttonPadding = 16;
    } else {
      imageHeight = 200;
      fontSize = 18;
      padding = 16;
      buttonPadding = 16;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              child: Image.network(
                product.imageUrl ?? '',
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: AppColors.coolGray,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.coolGray.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  'Disponible: ${product.stock}',
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Text(
                product.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(vertical: buttonPadding),
                    elevation: 1,
                  ),
                  child: const Text(
                    'Llevar al Carrito',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
