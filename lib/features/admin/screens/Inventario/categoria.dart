import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/widgets/categoria_widget.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/widgets/menu_lateral.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';

class CategoriaScreen extends StatefulWidget {
  const CategoriaScreen({super.key});

  @override
  _CategoriaScreenState createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _categoryController = TextEditingController();
  File? _selectedImage;
  String? _editingCategoryId;
  String? _editingImageUrl;
  bool _isLoading = false;
  bool _isFormVisible = false;

  Future<void> _addOrUpdateCategory() async {
    if (_categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingrese el nombre de la categoría')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _editingImageUrl;
      if (_selectedImage != null) {
        imageUrl =
            await _firebaseService.uploadImageToCloudinary(_selectedImage!);
      }

      if (_editingCategoryId == null) {
        // Crear nueva categoría
        await _firebaseService.addCategoryWithImage(
          name: _categoryController.text,
          imageUrl: imageUrl,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoría agregada exitosamente')),
        );
      } else {
        // Actualizar categoría existente
        await _firebaseService.updateCategory(
          id: _editingCategoryId!, // Asegúrate de usar el ID existente
          name: _categoryController.text,
          imageUrl: imageUrl,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoría actualizada exitosamente')),
        );
      }

      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la categoría: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isFormVisible = false;
      });
    }
  }

  void _clearFields() {
    _categoryController.clear();
    setState(() {
      _selectedImage = null;
      _editingCategoryId = null;
      _editingImageUrl = null;
    });
  }

  void _showForm({String? categoryId, String? categoryName, String? imageUrl}) {
    setState(() {
      _isFormVisible = true;
      _editingCategoryId = categoryId;
      _categoryController.text = categoryName ?? '';
      _editingImageUrl = imageUrl;
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return AdminScaffoldLayout(
      title: Row(
        children: [
          const Expanded(child: Text('Gestión de Categorías')),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showForm(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_isFormVisible)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _categoryController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de la Categoría',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  _selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            icon: Icon(Icons.upload),
                            label: Text('Subir Imagen'),
                          ),
                          if (_selectedImage != null)
                            Image.file(
                              _selectedImage!,
                              height: 150,
                            )
                          else if (_editingImageUrl != null)
                            Image.network(
                              _editingImageUrl!,
                              height: 150,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported),
                            ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isFormVisible = false;
                                    _clearFields();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: _addOrUpdateCategory,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _editingCategoryId == null
                                      ? Colors.green
                                      : Colors
                                          .blue, // Cambia el color del botón
                                ),
                                child: Text(
                                  _editingCategoryId == null
                                      ? 'Agregar'
                                      : 'Editar', // Cambia dinámicamente el texto
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _firebaseService.getCategoriesWithDetailsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error al cargar las categorías'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No hay categorías disponibles'));
                    }
                    final categories = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 2 : 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CategoriaWidget(
                          name: category['name'],
                          imageUrl: category['imageUrl'],
                          onTap: () {
                            _showForm(
                              categoryId: category['id'],
                              categoryName: category['name'],
                              imageUrl: category['imageUrl'],
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
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
