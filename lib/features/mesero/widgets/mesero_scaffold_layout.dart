import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/features/mesero/screens/nuevo_pedido/nuevo_pedido_screen.dart';
import 'package:restaurante_app/features/mesero/widgets/mesero_dashboard/sidebar_menu.dart';

class MeseroScaffoldLayout extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final Widget? floatingButton;

  const MeseroScaffoldLayout({
    super.key,
    required this.body,
    this.title,
    this.floatingButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenuMesero(),
      appBar: AppBar(
        title: title ??
            const Text(
              'Panel de Mesero',
              style: TextStyle(color: AppColors.white),
            ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: body,
      floatingActionButton: floatingButton ??
          FloatingActionButton.extended(
            icon: const Icon(Icons.add, color: AppColors.white),
            label: const Text(
              'Nuevo Pedido',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            backgroundColor: AppColors.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NuevoPedidoScreen(
                    mesaId: 'mesa_demo',
                    nombre: 'Mesa Demo',
                  ),
                ),
              );
            },
          ),
    );
  }
}
