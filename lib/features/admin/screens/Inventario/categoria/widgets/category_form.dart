import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/widgets/wbutton.dart';
import 'package:restaurante_app/core/widgets/wtext_field.dart';

class CategoryForm extends StatefulWidget {
  final Map<String, dynamic>? category;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const CategoryForm({
    super.key,
    this.category,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _controller = TextEditingController();
  final _firebaseService = FirebaseService();
  File? _image;
  String? _imageUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.category?['name'] ?? '';
    _imageUrl = widget.category?['imageUrl'];
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre obligatorio')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      String? imageUrl = _imageUrl;
      if (_image != null) {
        imageUrl = await _firebaseService.uploadImageToCloudinary(_image!);
      }

      if (widget.category == null) {
        await _firebaseService.addCategoryWithImage(
          name: _controller.text.trim(),
          imageUrl: imageUrl,
        );
      } else {
        await _firebaseService.updateCategory(
          id: widget.category!['id'],
          name: _controller.text.trim(),
          imageUrl: imageUrl,
        );
      }

      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        top: 24,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar Categoría' : 'Agregar Categoría',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onCancel,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              WTextField(
                controller: _controller,
                label: 'Nombre de Categoría',
              ),
              const SizedBox(height: 10),
              WButton(
                onPressed: () async {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => _image = File(picked.path));
                  }
                },
                icon: const Icon(Icons.image, color: Colors.white, size: 20),
                label: 'Seleccionar Imagen',
              ),
              const SizedBox(height: 10),
              if (_image != null)
                Image.file(_image!, height: 120)
              else if (_imageUrl != null)
                Image.network(
                  _imageUrl!,
                  height: 120,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: Text(isEditing ? 'Guardar' : 'Agregar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
