import 'package:flutter/material.dart';
import 'package:restaurante_app/routes/app_routes.dart';

class MenuLateralCaja extends StatelessWidget {
  const MenuLateralCaja({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('Cajero'),
            accountEmail: Text('cajero@example.com'),
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
                  leading: Icon(Icons.attach_money),
                  title: Text('Pedidos Listos'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.cashier);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Historial de Ventas'),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.historial);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text('Generar Facturas'),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.kitchenOrders); // Placeholder route
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
