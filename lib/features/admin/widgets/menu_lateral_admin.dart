import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import '../screens/dashboard.dart';
import '../screens/usuarios/gestion_usarios.dart';
import '../screens/reportes/reportes_ventas.dart';
import '../screens/Inventario/gestion_inventario.dart';
import '../screens/gastos/agregar_gasto.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

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
            // Encabezado con avatar, nombre y correo
            Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                      'assets/images/logo_2.png'), // Cambia según tu imagen
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

            // Tus opciones actuales con estilo mejorado
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
            _buildMenuItem(
              context,
              icon: Icons.inventory,
              title: 'Gestión de Inventario',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
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
                      // Lógica de manejo
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón rojo de "Salir"
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
}
