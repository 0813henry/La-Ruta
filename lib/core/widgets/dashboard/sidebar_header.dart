import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class SidebarHeader extends StatelessWidget {
  final String nombre;
  final String correo;
  final String rol;
  final String? imageAssetPath;

  const SidebarHeader({
    super.key,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.imageAssetPath = 'assets/images/logo_2.png',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(imageAssetPath!),
        ),
        const SizedBox(height: 12),
        Text(
          nombre,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          correo,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          rol,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
