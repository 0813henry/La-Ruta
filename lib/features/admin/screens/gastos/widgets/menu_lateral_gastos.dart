import 'package:flutter/material.dart';
import '../../dashboard.dart';
import '../../usuarios/gestion_usarios.dart';
import '../../reportes/reportes_ventas.dart';
import '../../Inventario/gestion_inventario.dart';
import '../agregar_gasto.dart';
import '../historial_gasto.dart';

class SidebarMenuGastos extends StatelessWidget {
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
                  leading: Icon(Icons.money_off),
                  title: Text('Agregar Gasto'),
                  onTap: () {
                    Navigator.pushReplacement(
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
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Historial de Gastos'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistorialGastoScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Salir'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
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
