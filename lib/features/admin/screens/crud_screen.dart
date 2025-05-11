import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';

class CrudScreen extends StatefulWidget {
  const CrudScreen({super.key});

  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage;
  String? _editingProductId;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl =
            await _firebaseService.uploadImageToCloudinary(_selectedImage!);
      }

      if (_editingProductId == null) {
        await _firebaseService.addProductWithImage(
          Product(
            id: '',
            name: _nameController.text,
            descripcion: _descriptionController.text,
            price: double.parse(_priceController.text),
            category: 'General',
            stock: 0,
            imageUrl: imageUrl,
            preparationTime: 0,
          ),
          _selectedImage,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto guardado exitosamente')),
        );
      } else {
        await _firebaseService.updateProduct(
          Product(
            id: _editingProductId!,
            name: _nameController.text,
            descripcion: _descriptionController.text,
            price: double.parse(_priceController.text),
            category: 'General',
            stock: 0,
            imageUrl: imageUrl,
            preparationTime: 0,
          ),
        );
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

  Future<void> _deleteItem(String productId) async {
    try {
      await _firebaseService.deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto: $e')),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _selectedImage = null;
      _editingProductId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD de Productos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _firebaseService.getProductsStream(),
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
                    return ExpansionTile(
                      title: Text(product.name),
                      subtitle: Text('Precio: ${product.price}'),
                      children: [
                        ListTile(
                          title: Text('Editar Producto'),
                          onTap: () {
                            setState(() {
                              _nameController.text = product.name;
                              _descriptionController.text = product.descripcion;
                              _priceController.text = product.price.toString();
                              _editingProductId = product.id;
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Eliminar Producto'),
                          onTap: () => _deleteItem(product.id),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nombre del Producto'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Seleccionar Imagen'),
                ),
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 150,
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveItem,
                  child: Text(_editingProductId == null
                      ? 'Guardar Producto'
                      : 'Actualizar Producto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
