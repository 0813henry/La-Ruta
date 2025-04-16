import 'package:flutter/material.dart';

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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: roles.map((role) {
            return ChoiceChip(
              label: Text(role),
              selected: selectedRole == role,
              onSelected: (selected) {
                if (selected) {
                  onRoleSelected(role);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
