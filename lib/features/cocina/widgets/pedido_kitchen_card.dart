import 'package:flutter/material.dart';
import 'timer_progress.dart';

class PedidoKitchenCard extends StatelessWidget {
  final String pedidoId;
  final String cliente;
  final String estado;
  final DateTime startTime;
  final Function()? onActionPressed;

  PedidoKitchenCard({
    required this.pedidoId,
    required this.cliente,
    required this.estado,
    required this.startTime,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              'Pedido $pedidoId',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              'Cliente: $cliente\nEstado: $estado',
              style: TextStyle(color: Colors.grey[700]),
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
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
