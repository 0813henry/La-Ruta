import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/features/admin/widgets/admin_dashboard/sidebar_menu.dart';

class AdminScaffoldLayout extends StatelessWidget {
  final Widget body;
  final Widget? title; // Permite personalizar el título opcionalmente

  const AdminScaffoldLayout({
    super.key,
    required this.body,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      appBar: AppBar(
        title: DefaultTextStyle(
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          child: title ?? const Text('Panel de Administración'),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(
          color: AppColors.white, // Cambia el color de los iconos a blanco
        ),
      ),
      body: body,
    );
  }
}
