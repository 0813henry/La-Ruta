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
      appBar: AppBar(
        title: Text('Caja - Pedidos Listos'),
        backgroundColor: AppColors.success,
      ),
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

          // Calcular el total general de todos los pedidos
          double totalGeneral = 0.0;
          for (final pedido in pedidos) {
            double pedidoTotal = pedido.total;
            if (pedido.divisiones != null && pedido.divisiones!.isNotEmpty) {
              double totalDiv = 0.0;
              pedido.divisiones!.forEach((_, items) {
                for (var item in items) {
                  final adicionalesTotal = item.adicionales.fold(
                    0.0,
                    (sum, adicional) => sum + (adicional['price'] as double),
                  );
                  totalDiv += (item.precio + adicionalesTotal) * item.cantidad;
                }
              });
              pedidoTotal += totalDiv;
            }
            totalGeneral += pedidoTotal;
          }

          return Column(
            children: [
              // Total arriba (en verde)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total General',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalGeneral.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];

                    double pedidoTotal = pedido.total;
                    if (pedido.divisiones != null &&
                        pedido.divisiones!.isNotEmpty) {
                      double totalDiv = 0.0;
                      pedido.divisiones!.forEach((_, items) {
                        for (var item in items) {
                          final adicionalesTotal = item.adicionales.fold(
                            0.0,
                            (sum, adicional) =>
                                sum + (adicional['price'] as double),
                          );
                          totalDiv +=
                              (item.precio + adicionalesTotal) * item.cantidad;
                        }
                      });
                      pedidoTotal += totalDiv;
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: tipoColor,
                              child: Icon(Icons.fastfood, color: Colors.white),
                            ),
                            title: Text(
                              pedido.cliente,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
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
                                    'Total: \$${pedidoTotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PagoScreen(pedido: pedido),
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
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
