import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import '../widgets/menu_lateral_caja.dart';
import 'pago_screen.dart';
import '../widgets/resumen_pago.dart';

class CajaHomeScreen extends StatelessWidget {
  final PedidoService _pedidoService = PedidoService();

  CajaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService().escucharNotificacionesCocina((mesaId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesa $mesaId lista para listo')),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text('Caja - Pedidos Listos')),
      drawer: MenuLateralCaja(),
      body: StreamBuilder<List<OrderModel>>(
        stream: _pedidoService.obtenerPedidosPorEstado('Listo'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('Error en el StreamBuilder: ${snapshot.error}');
            return Center(
              child: Text('Error al cargar los pedidos: ${snapshot.error}'),
            );
          }
          final pedidos = snapshot.data ?? [];
          if (pedidos.isEmpty) {
            return Center(
                child: Text(
                    'No hay pedidos con estado "Listo".')); // Fix incorrect message
          }
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];

              // Calcular total general (productos + divisiones)
              double totalGeneral = pedido.total;
              if (pedido.divisiones != null && pedido.divisiones!.isNotEmpty) {
                double totalDiv = 0.0;
                pedido.divisiones!.forEach((_, items) {
                  for (var item in items) {
                    final adicionalesTotal = item.adicionales.fold(
                      0.0,
                      (sum, adicional) => sum + (adicional['price'] as double),
                    );
                    totalDiv +=
                        (item.precio + adicionalesTotal) * item.cantidad;
                  }
                });
                totalGeneral += totalDiv;
              }

              Color tipoColor;
              switch (pedido.tipo.toLowerCase()) {
                case 'domicilio':
                  tipoColor = AppColors.domicilio;
                  break;
                case 'vip':
                  tipoColor = AppColors.vip;
                  break;
                case 'local':
                  tipoColor = AppColors.principal;
                  break;
                default:
                  tipoColor = AppColors.coolGray;
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tipoColor,
                    child: Icon(Icons.fastfood, color: Colors.white),
                  ),
                  title: Text(
                    pedido.cliente,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: tipoColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pedido.tipo.toUpperCase(),
                          style: TextStyle(
                            color: tipoColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Total: \$${totalGeneral.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PagoScreen(pedido: pedido),
                        ),
                      );
                    },
                    child: Text('Pagar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(80, 40),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
