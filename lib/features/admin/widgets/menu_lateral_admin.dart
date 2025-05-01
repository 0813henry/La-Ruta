import 'package:flutter/material.dart';
import '../screens/dashboard.dart';
import '../screens/usuarios/gestion_usarios.dart';
import '../screens/reportes/reportes_ventas.dart';
import '../screens/Inventario/gestion_inventario.dart';
import '../screens/gastos/agregar_gasto.dart';

class SidebarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Menú'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Gestión de Usuarios'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Reportes de Ventas'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text('Gestión de Inventario'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventoryScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.money_off),
            title: Text('Agregar Gasto'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AgregarGastoWidget(
                          onAgregar: (imagen, descripcion, valor) {
                            // Manejar el gasto agregado aquí
                          },
                        )),
              );
            },
          ),
          Divider(), // Separador visual
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Salir'),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, '/login'); // Navegar al login
            },
          ),
        ],
      ),
    );
  }
}
