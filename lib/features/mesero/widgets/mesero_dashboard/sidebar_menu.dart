import 'package:flutter/material.dart';
import 'package:restaurante_app/core/widgets/wbutton.dart';
import 'package:restaurante_app/core/widgets/dashboard/sidebar_header.dart';
import 'package:restaurante_app/core/widgets/dashboard/sidebar_menu_item.dart';
import 'package:restaurante_app/features/mesero/screens/pedidos_screen.dart';
import 'package:restaurante_app/features/mesero/screens/resumen_screen.dart';

class SidebarMenuMesero extends StatefulWidget {
  const SidebarMenuMesero({super.key});

  @override
  State<SidebarMenuMesero> createState() => _SidebarMenuMeseroState();
}

class _SidebarMenuMeseroState extends State<SidebarMenuMesero>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(animation),
          child: screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              const SidebarHeader(
                nombre: 'Mesero',
                correo: 'mesero@gmail.com',
                rol: 'Mesero',
              ),
              const SizedBox(height: 24),
              const Divider(),
              SidebarMenuItem(
                icon: Icons.dashboard,
                title: 'Pedidos Activos',
                onTap: () => _navigateTo(context, const OrdersScreen()),
              ),
              SidebarMenuItem(
                icon: Icons.receipt,
                title: 'Resumen de Pedidos',
                onTap: () => _navigateTo(context, const ResumenScreen()),
              ),
              const SizedBox(height: 20),
              WButton(
                label: 'Cerrar Sesión',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
