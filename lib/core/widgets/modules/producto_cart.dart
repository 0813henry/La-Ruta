import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/producto_model.dart';

class ProductoCart extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;

  const ProductoCart({
    Key? key,
    required this.product,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(
          vertical: screenWidth * 0.02, horizontal: screenWidth * 0.05),
      child: ListTile(
        leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
            ? Image.network(
                product.imageUrl!,
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                fit: BoxFit.cover,
              )
            : Icon(Icons.image_not_supported, size: screenWidth * 0.15),
        title:
            Text(product.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Precio: \$${product.price.toStringAsFixed(2)}'),
            Text('Categoría: ${product.category}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
