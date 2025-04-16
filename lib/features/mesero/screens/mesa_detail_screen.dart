import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/mesa_service.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import '../../../routes/app_routes.dart';

// Este archivo contiene la pantalla de detalles de una mesa, con opciones para tomar pedidos o cerrar cuenta.

class MesaDetailScreen extends StatelessWidget {
  final String mesaId;
  final String estado;

  const MesaDetailScreen({required this.mesaId, required this.estado, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Mesa $mesaId'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Estado: $estado'),
            leading: Icon(
              estado == 'Libre' ? Icons.check_circle : Icons.warning,
              color: estado == 'Libre' ? Colors.green : Colors.red,
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Tomar Pedido'),
            leading: Icon(Icons.restaurant_menu),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.nuevoPedido,
                arguments: {'mesaId': mesaId},
              );
            },
          ),
          ListTile(
            title: Text('Seguir Estado'),
            leading: Icon(Icons.track_changes),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.pedidos,
                arguments: {'mesaId': mesaId},
              );
            },
          ),
          ListTile(
            title: Text('Cerrar Mesa'),
            leading: Icon(Icons.payment),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cerrar Mesa'),
                  content: Text('¿Está seguro de cerrar la mesa $mesaId?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  // Obtener los pedidos asociados a la mesa
                  final pedidos =
                      await FirebaseService().getOrdersByMesaId(mesaId);

                  // Guardar las ventas en Firebase
                  for (var pedido in pedidos) {
                    await FirebaseService().saveMesaSales(pedido);
                  }

                  // Eliminar los pedidos de la mesa
                  await FirebaseService().deleteOrdersByMesaId(mesaId);

                  // Actualizar estado de la mesa a "Libre"
                  await MesaService().actualizarEstado(mesaId, 'Libre');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Mesa $mesaId cerrada exitosamente')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cerrar la mesa: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
