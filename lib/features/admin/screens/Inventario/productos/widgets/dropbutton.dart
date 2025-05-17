import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class WDropButtonFormField extends StatelessWidget {
  const WDropButtonFormField({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  final String? selectedCategory;
  final List<Map<String, dynamic>> categories;
  final Function(String? p1) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelText: 'Categoría',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      items: categories.map((category) {
        final categoryName = category['name'] as String? ?? 'Sin nombre';
        return DropdownMenuItem(
          value: categoryName,
          child: Text(categoryName,
              style: const TextStyle(color: AppColors.textPrimary)),
        );
      }).toList(),
      onChanged: onCategoryChanged,
    );
  }
}
