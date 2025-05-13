import 'package:flutter/material.dart';

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
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<String>(
        initialValue: selectedRole,
        onSelected: onRoleSelected,
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'admin', child: Text('Admin')),
          PopupMenuItem(value: 'cajero', child: Text('Cajero')),
          PopupMenuItem(value: 'mesero', child: Text('Mesero')),
          PopupMenuItem(value: 'cocina', child: Text('Cocina')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedRole == 'Seleccione un rol'
                    ? selectedRole
                    : selectedRole[0].toUpperCase() + selectedRole.substring(1),
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
