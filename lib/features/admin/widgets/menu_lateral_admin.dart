import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import '../screens/dashboard.dart';
import '../screens/usuarios/gestion_usuarios.dart';
import '../screens/reportes/reportes_ventas.dart';
import '../screens/Inventario/gestion_inventario.dart';
import '../screens/gastos/agregar_gasto.dart';
import '../screens/Inventario/categoria.dart';
import '../screens/Inventario/producto.dart';
import '../screens/Inventario/adicionales.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu>
    with SingleTickerProviderStateMixin {
  bool _inventarioExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  void _toggleInventario() {
    setState(() {
      _inventarioExpanded = !_inventarioExpanded;
      if (_inventarioExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/logo_2.png'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Jose pertuz',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'jose@gmail.com',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Administrador',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),

            _buildMenuItem(
              context,
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.people,
              title: 'Gestión de Usuarios',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UsersScreen()),
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.bar_chart,
              title: 'Reportes de Ventas',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              ),
            ),

            // Menú principal con botón para desplegar
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: const Icon(Icons.inventory, color: Colors.black87),
              title: const Text('Gestión de Inventario',
                  style: TextStyle(fontSize: 16)),
              trailing: Icon(
                _inventarioExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
              onTap: _toggleInventario,
            ),

            // Submenú animado
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1.0,
              child: Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  children: [
                    _buildSubMenuItem(
                      context,
                      icon: Icons.category,
                      title: 'Categorías',
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CategoriaScreen()),
                      ),
                    ),
                    _buildSubMenuItem(
                      context,
                      icon: Icons.shopping_bag,
                      title: 'Productos',
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductoScreen()),
                      ),
                    ),
                    _buildSubMenuItem(
                      context,
                      icon: Icons.add_circle,
                      title: 'Adicionales',
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdicionalesScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildMenuItem(
              context,
              icon: Icons.money_off,
              title: 'Agregar Gasto',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgregarGastoWidget(
                    onAgregar: (imagen, descripcion, valor) {
                      // lógica de gasto
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
      hoverColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSubMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 8),
      leading: Icon(icon, size: 20, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }
}
