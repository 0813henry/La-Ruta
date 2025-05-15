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
    super.key,
  });

  @override
  _ProductoGridState createState() => _ProductoGridState();
}

class _ProductoGridState extends State<ProductoGrid> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';
  String _selectedTipo = 'Todos';

  List<String> tipos = ['Todos', 'Local', 'Domicilio', 'VIP'];

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar recetas, productos o usuarios',
          prefixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget buildTipoDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButton<String>(
        value: _selectedTipo,
        items: tipos.map((String valor) {
          return DropdownMenuItem<String>(
            value: valor,
            child: Text(valor),
          );
        }).toList(),
        onChanged: (String? nuevoValor) {
          setState(() {
            _selectedTipo = nuevoValor!;
          });
        },
        isExpanded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        buildSearchBar(), // Barra de búsqueda estilizada
        buildTipoDropdown(), // Menú desplegable tipo filtro
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
                      product.name.toLowerCase().contains(_searchQuery) &&
                      (_selectedTipo == 'Todos' ||
                          (product.category ?? '') == _selectedTipo))
                  .toList();
              return ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple[100],
                      backgroundImage: product.imageUrl != null
                          ? NetworkImage(product.imageUrl!)
                          : null,
                      child: product.imageUrl == null
                          ? Icon(Icons.fastfood)
                          : null,
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                        'Precio: \$${product.price.toStringAsFixed(2)} | Stock: ${product.stock}'),
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart),
                      onPressed: () => widget.onAddToCart(product),
                    ),
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
