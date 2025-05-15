import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class MenuLateralMesero extends StatelessWidget {
  const MenuLateralMesero({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('Mesero'),
            accountEmail: Text('mesero@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'M',
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.restaurant_menu),
                  title: Text('Pedidos Activos'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.pedidos);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text('Resumen de Pedidos'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.resumen);
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
