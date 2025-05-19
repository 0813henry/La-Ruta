import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/features/mesero/screens/nuevo_pedido/nuevo_pedido_screen.dart';
import 'package:restaurante_app/features/mesero/widgets/mesero_dashboard/sidebar_menu.dart';

class MeseroScaffoldLayout extends StatelessWidget {
  final Widget body;
  final Widget? title; // Permite personalizar el título opcionalmente

  const MeseroScaffoldLayout({
    super.key,
    required this.body,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenuMesero(),
      appBar: AppBar(
        title: title ?? const Text('Panel de Mesero'),
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add, color: AppColors.white),
        label: Text(
          'Nuevo Pedido',
          style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NuevoPedidoScreen(
                mesaId: 'mesa_demo', // Reemplaza con el ID real de la mesa
                nombre: 'Mesa Demo', // Reemplaza con el nombre real de la mesa
              ),
            ),
          );
        },
      ),
    );
  }
}
