import 'package:flutter/material.dart';
import '../../../core/widgets/menu_lateral.dart';
import 'usuarios/gestion_usarios.dart';
import 'reportes/reportes_ventas.dart';
import 'Inventario/gestion_inventario.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: SidebarMenu(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              Wrap(
                spacing: screenWidth * 0.05,
                runSpacing: screenWidth * 0.05,
                alignment: WrapAlignment.center,
                children: [
                  CardWidget(
                    title: 'Resumen de Inventario',
                    description: 'Stock de productos: 100',
                    icon: Icons.inventory,
                  ),
                  CardWidget(
                    title: 'Ingresos y Egresos',
                    description: 'Gráficos de ingresos y egresos',
                    icon: Icons.bar_chart,
                  ),
                  CardWidget(
                    title: 'Pedidos Activos',
                    description: 'Número de pedidos activos: 5',
                    icon: Icons.shopping_cart,
                  ),
                  CardWidget(
                    title: 'Gestión de Usuarios',
                    description: 'Administrar usuarios del sistema',
                    icon: Icons.people,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UsersScreen()),
                      );
                    },
                  ),
                  CardWidget(
                    title: 'Reportes',
                    description: 'Ver reportes de ventas',
                    icon: Icons.bar_chart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReportsScreen()),
                      );
                    },
                  ),
                  CardWidget(
                    title: 'Gestión de Inventario',
                    description: 'Administrar inventario de productos',
                    icon: Icons.inventory,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InventoryScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Function()? onTap;

  const CardWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 600 ? screenWidth * 0.8 : screenWidth * 0.4;

    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: screenWidth * 0.1,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: screenWidth * 0.03),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
          // Agrega más opciones de navegación aquí
        ],
      ),
    );
  }
}

class CategoriaWidget extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CategoriaWidget({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(imageUrl),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
          Text(name),
        ],
      ),
    );
  }
}
