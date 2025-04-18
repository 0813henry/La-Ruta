import 'package:flutter/material.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/categoria.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/producto.dart';
import '../../features/admin/screens/dashboard.dart';
import '../../features/admin/screens/usuarios/gestion_usarios.dart';
import '../../features/admin/screens/reportes/reportes_ventas.dart';
import '../../features/admin/screens/Inventario/gestion_inventario.dart';
import '../../routes/app_routes.dart';

class SidebarMenuInventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('Usuario'),
            accountEmail: Text('usuario@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'U',
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text('Dashboard'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashboardScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.inventory),
                  title: Text('Gestión de Inventario'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InventoryScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.category),
                  title: Text('Categorías'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CategoriaScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text('Productos'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProductoScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Salir'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
