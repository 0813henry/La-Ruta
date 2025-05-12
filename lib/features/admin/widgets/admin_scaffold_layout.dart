import 'package:flutter/material.dart';
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
        title: title ?? const Text('Panel de Administración'),
      ),
      body: body,
    );
  }
}
