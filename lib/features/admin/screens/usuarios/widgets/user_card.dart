import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/usuario_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const UserCard({
    super.key,
    required this.user,
    required this.onToggle,
    required this.onEdit,
  });
  String capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 20, right: 10, bottom: 3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.2),
              blurRadius: 1,
              offset: Offset(0, 0))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.secondary,
            backgroundImage:
                user.color.startsWith('http') ? NetworkImage(user.color) : null,
            child: user.color.startsWith('http')
                ? null
                : const Icon(Icons.person, size: 30, color: AppColors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  capitalize(user.role),
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phone,
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(user.isActive ? Icons.toggle_on : Icons.toggle_off,
                    size: 30,
                    color:
                        user.isActive ? AppColors.accent : AppColors.cancelado),
                onPressed: () => onToggle(!user.isActive),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: onEdit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
