import 'dart:io';
import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/widgets/wbutton.dart';
import 'package:restaurante_app/core/widgets/wtext_field.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/productos/widgets/dropbutton.dart';

class AddEditProductFormSheet extends StatelessWidget {
  final FirebaseService firebaseService;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController preparationTimeController;
  final dynamic selectedImage;
  final String? selectedCategory;
  final String? editingProductId;
  final String? editingImageUrl;
  final VoidCallback onImagePick;
  final Function(String?) onCategoryChanged;
  final VoidCallback onSubmit;

  const AddEditProductFormSheet({
    super.key,
    required this.firebaseService,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.preparationTimeController,
    required this.selectedImage,
    required this.selectedCategory,
    required this.editingProductId,
    required this.editingImageUrl,
    required this.onImagePick,
    required this.onCategoryChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                editingProductId == null
                    ? 'Agregar Producto'
                    : 'Modificar Producto',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: firebaseService.getCategoriesWithDetailsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text('Error al cargar las categorías');
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay categorías disponibles');
                  }

                  final categories = snapshot.data!;
                  return WDropButtonFormField(
                      selectedCategory: selectedCategory,
                      categories: categories,
                      onCategoryChanged: onCategoryChanged);
                },
              ),
              const SizedBox(height: 10),
              WTextField(
                  controller: nameController, label: 'Nombre del Producto'),
              const SizedBox(height: 10),
              WTextField(
                  controller: descriptionController, label: 'Descripción'),
              const SizedBox(height: 10),
              WTextField(
                controller: priceController,
                label: 'Precio',
                keyboardType:
                    TextInputType.number, // Permitir solo números decimales),
              ),
              const SizedBox(height: 10),
              WTextField(
                controller: preparationTimeController,
                label: 'Tiempo de Preparación (minutos)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              WButton(
                label: 'Seleccionar Imagen',
                onPressed: onImagePick,
                icon: const Icon(Icons.image, color: AppColors.white),
              ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    File(selectedImage.path),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              else if (editingImageUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.network(
                    editingImageUrl!,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 100),
                  ),
                ),
              WButton(
                onPressed: () {
                  Navigator.pop(context);
                  onSubmit();
                },
                label: editingProductId == null
                    ? 'Agregar Producto'
                    : 'Actualizar Producto',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
