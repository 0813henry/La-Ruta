import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/constants/app_styles.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleSelected;

  const RoleSelector({
    required this.selectedRole,
    required this.onRoleSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roles = ['admin', 'cajero', 'mesero', 'cocina'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Rol:',
          style: AppStyles.subheading,
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: roles.map((role) {
            return ChoiceChip(
              label: Text(
                role,
                style: AppStyles.body.copyWith(
                  color: selectedRole == role
                      ? AppColors.white
                      : AppColors.textPrimary,
                ),
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.coolGray,
              onSelected: (selected) {
                if (selected) {
                  onRoleSelected(role);
                }
              }, selected: selectedRole == role,
            );
          }).toList(),
        ),
      ],
    );
  }
}
