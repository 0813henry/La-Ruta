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
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          ListTile(
            title: Text('Pedido $pedidoId'),
            subtitle: Text('Cliente: $cliente\nEstado: $estado'),
            trailing: onActionPressed != null
                ? IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: onActionPressed,
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TimerProgress(
              startTime: startTime,
              maxDuration: Duration(minutes: 30), // Example max duration
            ),
          ),
        ],
      ),
    );
  }
}
