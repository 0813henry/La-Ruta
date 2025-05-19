import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/features/cocina/screens/pedido_detail_screen.dart';
import 'package:restaurante_app/features/mesero/screens/detalles_mesa/dividir_cuenta_screen.dart';
import 'package:restaurante_app/features/mesero/screens/nuevo_pedido/nuevo_pedido_screen.dart';

class PedidoCard extends StatelessWidget {
  final OrderModel pedido;

  const PedidoCard({super.key, required this.pedido});

  Color _colorTipoPedido(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'domicilio':
        return AppColors.domicilio;
      case 'vip':
        return AppColors.vip;
      case 'local':
        return AppColors.principal;
      default:
        return AppColors.coolGray;
    }
  }

  Color _colorEstadoPedido(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return AppColors.pendiente;
      case 'en proceso':
        return AppColors.enProceso;
      case 'listo':
        return AppColors.listoParaServir;
      case 'en camino':
        return AppColors.enCamino;
      case 'entregado':
        return AppColors.entregado;
      case 'cancelado':
        return AppColors.cancelado;
      default:
        return AppColors.coolGray;
    }
  }

  double _calcularTotal() {
    double total = pedido.total;
    if (pedido.divisiones != null && pedido.divisiones!.isNotEmpty) {
      double totalDiv = 0.0;
      pedido.divisiones!.forEach((_, items) {
        for (var item in items) {
          final adicionalesTotal = item.adicionales.fold(
              0.0, (sum, adicional) => sum + (adicional['price'] as double));
          totalDiv += (item.precio + adicionalesTotal) * item.cantidad;
        }
      });
      total += totalDiv;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _colorTipoPedido(pedido.tipo),
          child: const Icon(Icons.fastfood, color: Colors.white),
        ),
        title: Text(pedido.cliente),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _colorEstadoPedido(pedido.estado),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pedido.estado,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(pedido.tipo),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Total: \$${_calcularTotal().toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Editar',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NuevoPedidoScreen(
                      mesaId: pedido.id ?? 'mesa_demo',
                      nombre: pedido.cliente,
                      pedido: pedido,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.call_split, color: Colors.green),
              tooltip: 'Dividir Cuenta',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DividirCuentaScreen(
                      mesaId: pedido.id ?? '',
                      productos: List<OrderItem>.from(pedido.items),
                      pedido: pedido,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PedidoDetailScreen(pedido: pedido),
            ),
          );
        },
      ),
    );
  }
}
