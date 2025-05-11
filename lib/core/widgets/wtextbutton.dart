import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class WTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const WTextButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary, // Color del tema
        ),
      ),
    );
  }
}
