import 'package:flutter/material.dart';
import '../../../core/widgets/modules/categoria_card.dart';
import '../../../core/services/servicio_firebase.dart';
import '../../../core/model/producto_model.dart';

// Este archivo contiene un widget que organiza productos en un grid con funcionalidad de búsqueda.

class ProductoGrid extends StatefulWidget {
  final Function(Product) onAddToCart;
  final Function(Product) onRemoveFromCart;

  const ProductoGrid({
    required this.onAddToCart,
    required this.onRemoveFromCart,
    Key? key,
  }) : super(key: key);

  @override
  _ProductoGridState createState() => _ProductoGridState();
}

class _ProductoGridState extends State<ProductoGrid> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Buscar producto',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Product>>(
            stream: _firebaseService.getProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay productos disponibles.'));
              }
              final filteredProducts = snapshot.data!
                  .where((product) =>
                      product.name.toLowerCase().contains(_searchQuery))
                  .toList();
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWideScreen ? 3 : 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(
                    title: product.name,
                    description: product.descripcion,
                    price: product.price,
                    imageUrl: product.imageUrl ?? '',
                    stock: product.stock,
                    category: product.category,
                    onAddToCart: () => widget.onAddToCart(product),
                    onRemoveFromCart: () => widget.onRemoveFromCart(product),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
