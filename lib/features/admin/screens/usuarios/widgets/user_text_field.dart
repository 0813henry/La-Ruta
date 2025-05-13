import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class UserTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool obscure;
  final String initial;
  final ValueChanged<String> onChanged;

  const UserTextField({
    super.key,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.initial = '',
    required this.onChanged,
  });

  @override
  State<UserTextField> createState() => _UserTextFieldState();
}

class _UserTextFieldState extends State<UserTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      obscureText: widget.obscure,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(widget.icon, color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
