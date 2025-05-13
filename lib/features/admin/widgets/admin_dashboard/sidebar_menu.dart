import 'package:flutter/material.dart';
import 'package:restaurante_app/core/widgets/wbutton.dart';
import 'package:restaurante_app/features/admin/screens/gastos/historial_gasto.dart';
import 'package:restaurante_app/features/admin/widgets/admin_dashboard/wigets/sidebar_expandable_section.dart';
import 'package:restaurante_app/features/admin/widgets/admin_dashboard/wigets/sidebar_header.dart';
import 'package:restaurante_app/features/admin/widgets/admin_dashboard/wigets/sidebar_menu_item.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/adicionales.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/categoria.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/producto.dart';
import 'package:restaurante_app/features/admin/screens/dashboard.dart';
import 'package:restaurante_app/features/admin/screens/reportes/reportes_ventas.dart';
import 'package:restaurante_app/features/admin/screens/usuarios/gestion_usuarios.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu>
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
              const SidebarHeader(),
              const SizedBox(height: 24),
              const Divider(),
              SidebarMenuItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () => _navigateTo(context, const DashboardScreen()),
              ),
              SidebarMenuItem(
                icon: Icons.people,
                title: 'Empleados',
                onTap: () => _navigateTo(context, UsersScreen()),
              ),
              SidebarMenuItem(
                icon: Icons.bar_chart,
                title: 'Ventas',
                onTap: () => _navigateTo(context, const ReportsScreen()),
              ),
              SidebarExpandableSection(
                title: 'Inventario',
                icon: Icons.inventory,
                children: [
                  SidebarMenuItem(
                    icon: Icons.category,
                    title: 'Categorías',
                    onTap: () => _navigateTo(context, CategoriaScreen()),
                    isSubItem: true,
                  ),
                  SidebarMenuItem(
                    icon: Icons.shopping_bag,
                    title: 'Productos',
                    onTap: () => _navigateTo(context, ProductoScreen()),
                    isSubItem: true,
                  ),
                  SidebarMenuItem(
                    icon: Icons.add_circle,
                    title: 'Adicionales',
                    onTap: () => _navigateTo(context, AdicionalesScreen()),
                    isSubItem: true,
                  ),
                ],
              ),
              SidebarMenuItem(
                icon: Icons.money_off,
                title: 'Gastos',
                onTap: () => _navigateTo(context, HistorialGastoScreen()),
              ),
              const SizedBox(height: 20),
              WButton(
                label: 'Cerrar Sesion',
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
