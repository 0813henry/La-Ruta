import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/images/logo_2.png'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Jose pertuz',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'jose@gmail.com',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          'Administrador',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
