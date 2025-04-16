import 'package:flutter/material.dart';
import 'package:restaurante_app/features/admin/screens/dashboard.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/categoria.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/producto.dart';
import 'package:restaurante_app/core/widgets/categoria_filter_widget.dart';
import 'package:restaurante_app/core/widgets/menu_lateral.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Inventario'),
      ),
      drawer: SidebarMenuInventory(),
      body: Column(
        children: [
          CategoriaFilterWidget(
            onFilterSelected: (selectedCategory) {
              setState(() {
                _selectedCategory = selectedCategory;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream:
                  _firebaseService.getFilteredProductsStream(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los productos'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay productos disponibles'));
                }
                final products = snapshot.data!;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final TextEditingController stockController =
                        TextEditingController(
                      text: product.stock.toString(),
                    );
                    return ListTile(
                      leading: product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? Image.network(product.imageUrl!,
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              fit: BoxFit.cover)
                          : Icon(Icons.image_not_supported),
                      title: Text(product.name),
                      subtitle: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () async {
                              final newStock = product.stock - 1;
                              if (newStock >= 0) {
                                await _firebaseService.updateProduct(
                                  product.copyWith(stock: newStock),
                                );
                              }
                            },
                          ),
                          SizedBox(
                            width: screenWidth * 0.1,
                            child: TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) async {
                                final newStock =
                                    int.tryParse(value) ?? product.stock;
                                if (newStock >= 0) {
                                  await _firebaseService.updateProduct(
                                    product.copyWith(stock: newStock),
                                  );
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              final newStock = product.stock + 1;
                              await _firebaseService.updateProduct(
                                product.copyWith(stock: newStock),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InventorySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Gestión de Inventario'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Gestión de Inventario'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InventoryScreen()),
            ),
          ),
          ListTile(
            title: Text('Gestión de Categorías'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoriaScreen()),
            ),
          ),
          ListTile(
            title: Text('Gestión de Productos'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductoScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
