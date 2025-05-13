import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/services/servicio_cloudinary.dart';

class UploadImageButton extends StatelessWidget {
  final void Function(String imageUrl) onImageUploaded;
  final CloudinaryService cloudinaryService;

  const UploadImageButton({
    super.key,
    required this.onImageUploaded,
    required this.cloudinaryService,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final picker = ImagePicker();
            final file = await picker.pickImage(source: ImageSource.gallery);
            if (file != null) {
              final url = await cloudinaryService.uploadImage(File(file.path));
              if (url != null) {
                onImageUploaded(url);
              }
            }
          },
          icon: const Icon(Icons.upload, color: AppColors.white),
          label: const Text(
            'Subir Foto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }
}
