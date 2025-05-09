import 'package:flutter/material.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/adicionales.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/categoria.dart';
import 'package:restaurante_app/features/admin/screens/Inventario/producto.dart';
import '../../dashboard.dart';
import '../../usuarios/gestion_usarios.dart';
import '../../reportes/reportes_ventas.dart';
import '../gestion_inventario.dart';
import '../../../../../routes/app_routes.dart';

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
                ListTile(
                  leading: Icon(Icons.add_circle),
                  title: Text('Adicionales'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdicionalesScreen()),
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
