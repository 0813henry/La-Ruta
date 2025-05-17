import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'timer_progress.dart';

class PedidoKitchenCard extends StatelessWidget {
  final String cliente;
  final String estado;
  final DateTime startTime;
  final String? tipo;
  final Function()? onActionPressed;

  const PedidoKitchenCard({
    super.key,
    required this.cliente,
    required this.estado,
    required this.startTime,
    this.tipo,
    this.onActionPressed,
  });

  Color _colorTipoPedido(String? tipo) {
    switch ((tipo ?? '').toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground, // <-- Color de fondo neutro
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: BorderSide(color: _colorTipoPedido(tipo), width: 2),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _colorTipoPedido(tipo),
              child: Icon(Icons.fastfood, color: Colors.white),
            ),
            title: Text(
              cliente,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _colorTipoPedido(tipo).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tipo?.toUpperCase() ?? '',
                      style: TextStyle(
                        color: _colorTipoPedido(tipo),
                        fontWeight: FontWeight.bold,
                        fontSize: 7, // <-- Cambia de 14 a 12
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      estado,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: onActionPressed != null
                ? IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: onActionPressed,
                  )
                : null,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TimerProgress(
              startTime: startTime,
              maxDuration: Duration(minutes: 30),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Tiempo restante: ${_formatRemainingTime()}',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemainingTime() {
    final remaining =
        startTime.add(Duration(minutes: 30)).difference(DateTime.now());
    if (remaining.isNegative) return 'Tiempo agotado';
    return '${remaining.inMinutes} min ${remaining.inSeconds % 60} seg';
  }
}
