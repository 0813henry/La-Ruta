import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/widgets/categoria_filter_widget.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/core/widgets/modules/producto_cart.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/productos/widgets/add_edit_product_button.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';

class ProductoScreen extends StatefulWidget {
  const ProductoScreen({super.key});

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

    return AdminScaffoldLayout(
      title: Row(
        children: [
          const Expanded(child: Text('Gestión de Productos')),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _clearFields();
              });
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddEditProductFormSheet(
                  firebaseService: _firebaseService,
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  priceController: _priceController,
                  preparationTimeController: _preparationTimeController,
                  selectedImage: _selectedImage,
                  selectedCategory: _selectedCategory,
                  editingProductId: _editingProductId,
                  editingImageUrl: _editingImageUrl,
                  onImagePick: _pickImage,
                  onCategoryChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  onSubmit: _addOrUpdateProduct,
                ),
              );
            },
          ),
        ],
      ),
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
                            _preparationTimeController.text =
                                product.preparationTime.toString();
                            _selectedCategory = product.category;
                            _editingProductId = product.id;
                            _editingImageUrl = product.imageUrl;
                            _selectedImage = null;
                          });

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => AddEditProductFormSheet(
                              firebaseService: _firebaseService,
                              nameController: _nameController,
                              descriptionController: _descriptionController,
                              priceController: _priceController,
                              preparationTimeController:
                                  _preparationTimeController,
                              selectedImage: _selectedImage,
                              selectedCategory: _selectedCategory,
                              editingProductId: _editingProductId,
                              editingImageUrl: _editingImageUrl,
                              onImagePick: _pickImage,
                              onCategoryChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              onSubmit: _addOrUpdateProduct,
                            ),
                          );
                        });
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
