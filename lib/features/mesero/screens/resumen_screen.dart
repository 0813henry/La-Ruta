import 'package:flutter/material.dart';
import '../../../core/services/pedido_service.dart';
import '../../../core/widgets/modules/pedido_item.dart';
import '../../../core/model/pedido_model.dart';
import '../widgets/mesero_dashboard/menu_lateral_mesero.dart';
import '../../../core/constants/app_colors.dart';
import 'detalles_mesa/pedido_detail_screen.dart'; // <-- Importa la pantalla de detalle

class ResumenScreen extends StatelessWidget {
  const ResumenScreen({super.key});

  double _pedidoTotalGeneral(OrderModel pedido) {
    double total = 0.0;
    // Suma productos principales
    total += pedido.items.fold(0.0, (sum, item) {
      final adicionalesTotal = item.adicionales.fold(
        0.0,
        (sum, adicional) => sum + (adicional['price'] as double),
      );
      return sum + (item.precio + adicionalesTotal) * item.cantidad;
    });
    // Suma todas las divisiones
    if (pedido.divisiones != null && pedido.divisiones!.isNotEmpty) {
      pedido.divisiones!.forEach((_, items) {
        total += items.fold(0.0, (sum, item) {
          final adicionalesTotal = item.adicionales.fold(
            0.0,
            (sum, adicional) => sum + (adicional['price'] as double),
          );
          return sum + (item.precio + adicionalesTotal) * item.cantidad;
        });
      });
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Pedidos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
      ),
      drawer: MenuLateralMesero(),
      body: Container(
        color: AppColors.background,
        child: StreamBuilder<List<OrderModel>>(
          stream: PedidoService().obtenerPedidosPorEstado('Pagado'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final pedidos = snapshot.data ?? [];
            if (pedidos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long,
                        size: 80, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'No hay pedidos vendidos.',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            // Sumar el total general de cada pedido (incluyendo divisiones)
            final total = pedidos.fold(
                0.0, (sum, pedido) => sum + _pedidoTotalGeneral(pedido));

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Vendido',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: pedidos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final pedido = pedidos[index];
                      final totalGeneralPedido = _pedidoTotalGeneral(pedido);
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        color: AppColors.cardBackground,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.accent.withOpacity(0.15),
                            child:
                                Icon(Icons.receipt, color: AppColors.primary),
                          ),
                          title: Text(
                            'Cliente: ${pedido.cliente}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total: \$${totalGeneralPedido.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Tipo: ${pedido.tipo}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Estado: ${pedido.estado}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios_rounded,
                              color: AppColors.primary, size: 18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PedidoDetailScreen(pedido: pedido),
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
      ),
    );
  }
}
