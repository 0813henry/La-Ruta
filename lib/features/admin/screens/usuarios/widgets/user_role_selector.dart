import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class UserRoleSelector extends StatelessWidget {
  final String selectedRole;
  final void Function(String) onRoleSelected;

  const UserRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = (screenWidth * 0.8).clamp(250.0, 500.0);

    return Center(
      child: Container(
        width: containerWidth,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          offset: const Offset(0, 60),
          initialValue: selectedRole,
          onSelected: onRoleSelected,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'admin',
              child: SizedBox(
                width: containerWidth,
                child: const Text('Administrador'),
              ),
            ),
            PopupMenuItem(
              value: 'cajero',
              child: SizedBox(
                width: containerWidth,
                child: const Text('Cajero'),
              ),
            ),
            PopupMenuItem(
              value: 'mesero',
              child: SizedBox(
                width: containerWidth,
                child: const Text('Mesero'),
              ),
            ),
            PopupMenuItem(
              value: 'cocina',
              child: SizedBox(
                width: containerWidth,
                child: const Text('Cocina'),
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedRole == 'Seleccione un rol'
                        ? selectedRole
                        : selectedRole[0].toUpperCase() +
                            selectedRole.substring(1),
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
