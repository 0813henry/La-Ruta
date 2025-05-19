import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/features/admin/widgets/admin_dashboard/controller/sidebar_controller.dart';

class SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSubItem;

  const SidebarMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSubItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SidebarController.activeItem,
      builder: (context, activeTitle, _) {
        final bool isSelected = title == activeTitle;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(left: isSubItem ? 24 : 0, bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? AppColors.background : AppColors.secondary,
              ),
            ),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? AppColors.background : AppColors.textSecondary,
              ),
              child: Text(title),
            ),
            onTap: () {
              SidebarController.setActiveItem(title);
              onTap();
            },
          ),
        );
      },
    );
  }
}
