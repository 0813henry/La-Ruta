import 'package:flutter/material.dart';
import 'package:restaurante_app/features/cocina/screens/cocina_home_screen.dart';
import 'package:restaurante_app/features/cocina/screens/tiempos_screen.dart';
import 'package:restaurante_app/routes/app_routes.dart';

class MenuLateralCocina extends StatelessWidget {
  const MenuLateralCocina({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('Cocinero'),
            accountEmail: Text('cocinero@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'C',
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
                  title: Text('Kanban de Pedidos'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CocinaHomeScreen()),
                    );
                  },
                ),
                // ListTile(
                //   leading: Icon(Icons.timer),
                //   title: Text('Tiempos de Preparación'),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => TiemposScreen()),
                //     );
                //   },
                // ),
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
