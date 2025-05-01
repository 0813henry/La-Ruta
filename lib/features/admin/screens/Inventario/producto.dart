import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/widgets/categoria_filter_widget.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/widgets/menu_lateral.dart';
import 'package:restaurante_app/core/widgets/modules/producto_cart.dart';

class ProductoScreen extends StatefulWidget {
  @override
  _ProductoScreenState createState() => _ProductoScreenState();
}

class _ProductoScreenState extends State<ProductoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _preparationTimeController =
      TextEditingController();
  dynamic _selectedImage;
  String? _selectedCategory;
  String? _filterCategory;
  String? _editingProductId;
  String? _editingImageUrl;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _addOrUpdateProduct() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _preparationTimeController.text.isEmpty || // Validación del nuevo campo
        (_selectedImage == null && _editingImageUrl == null) ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    try {
      final product = Product(
        id: _editingProductId ?? '',
        name: _nameController.text,
        descripcion: _descriptionController.text,
        price: double.parse(_priceController.text),
        category: _selectedCategory!,
        stock: 0,
        imageUrl: _editingImageUrl,
        preparationTime:
            int.parse(_preparationTimeController.text), // Nuevo campo
      );

      if (_editingProductId == null) {
        await _firebaseService.addProductWithImage(product, _selectedImage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto agregado exitosamente')),
        );
      } else {
        if (_selectedImage != null) {
          product.imageUrl =
              await _firebaseService.uploadImage(File(_selectedImage.path));
        }
        await _firebaseService.updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto actualizado exitosamente')),
        );
      }

      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el producto: $e')),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _preparationTimeController.clear(); // Limpieza del nuevo campo
    setState(() {
      _selectedImage = null;
      _selectedCategory = null;
      _editingProductId = null;
      _editingImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _clearFields();
              });
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _editingProductId == null
                                  ? 'Agregar Producto'
                                  : 'Modificar Producto',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            StreamBuilder<List<Map<String, dynamic>>>(
                              stream: _firebaseService
                                  .getCategoriesWithDetailsStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error al cargar las categorías');
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Text('No hay categorías disponibles');
                                }
                                final categories = snapshot.data!;
                                return DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: InputDecoration(
                                    labelText: 'Categoría',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  items: categories.map((category) {
                                    final categoryName =
                                        category['name'] as String? ??
                                            'Sin nombre';
                                    return DropdownMenuItem(
                                      value: categoryName,
                                      child: Text(categoryName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nombre del Producto',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Descripción',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Precio',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _preparationTimeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Tiempo de Preparación (minutos)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: Text('Seleccionar Imagen'),
                            ),
                            if (_selectedImage != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Image.file(
                                  File(_selectedImage.path),
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else if (_editingImageUrl != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Image.network(
                                  _editingImageUrl!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.image_not_supported,
                                          size: 100),
                                ),
                              ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _addOrUpdateProduct();
                              },
                              child: Text(_editingProductId == null
                                  ? 'Agregar Producto'
                                  : 'Actualizar Producto'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: SidebarMenuInventory(),
      body: Column(
        children: [
          CategoriaFilterWidget(
            onFilterSelected: (selectedCategory) {
              setState(() {
                _filterCategory = selectedCategory;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream:
                  _firebaseService.getFilteredProductsStream(_filterCategory),
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
                    final product = products[products.length - 1 - index];
                    return ProductoCart(
                      product: product,
                      onEdit: () {
                        setState(() {
                          _nameController.text = product.name;
                          _descriptionController.text = product.descripcion;
                          _priceController.text = product.price.toString();
                          _selectedCategory = product.category;
                          _editingProductId = product.id;
                          _editingImageUrl = product.imageUrl;
                          _selectedImage = null;
                        });
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              left: 16,
                              right: 16,
                              top: 16,
                            ),
                            child: SingleChildScrollView(
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Modificar Producto',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      StreamBuilder<List<Map<String, dynamic>>>(
                                        stream: _firebaseService
                                            .getCategoriesWithDetailsStream(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error al cargar las categorías');
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return Text(
                                                'No hay categorías disponibles');
                                          }
                                          final categories = snapshot.data!;
                                          return DropdownButtonFormField<
                                              String>(
                                            value: _selectedCategory,
                                            decoration: InputDecoration(
                                              labelText: 'Categoría',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            items: categories.map((category) {
                                              final categoryName =
                                                  category['name'] as String? ??
                                                      'Sin nombre';
                                              return DropdownMenuItem(
                                                value: categoryName,
                                                child: Text(categoryName),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedCategory = value;
                                              });
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      TextField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Nombre del Producto',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextField(
                                        controller: _descriptionController,
                                        decoration: InputDecoration(
                                          labelText: 'Descripción',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextField(
                                        controller: _priceController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Precio',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextField(
                                        controller: _preparationTimeController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Tiempo de Preparación (minutos)',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _pickImage,
                                        child: Text('Seleccionar Imagen'),
                                      ),
                                      if (_selectedImage != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Image.file(
                                            File(_selectedImage.path),
                                            height: 150,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else if (_editingImageUrl != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Image.network(
                                            _editingImageUrl!,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Icon(Icons.image_not_supported,
                                                    size: 100),
                                          ),
                                        ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _addOrUpdateProduct();
                                        },
                                        child: Text('Actualizar Producto'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
