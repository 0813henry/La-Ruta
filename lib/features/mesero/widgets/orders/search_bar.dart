import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class SearchBarPedidos extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchBarPedidos({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(5),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Buscar por cliente o mesa',
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
