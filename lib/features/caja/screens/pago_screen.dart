import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/caja_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/model/transaccion_model.dart'
    as transaccion_model;
import 'package:restaurante_app/features/caja/widgets/metodo_pago_selector.dart';
import 'package:restaurante_app/features/caja/widgets/resumen_pago.dart';

class PagoScreen extends StatefulWidget {
  final OrderModel pedido;

  const PagoScreen({required this.pedido, Key? key}) : super(key: key);

  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final CajaService _cajaService = CajaService();
  final PedidoService _pedidoService = PedidoService();
  String _metodoPago = 'Efectivo';

  void _procesarPago() async {
    try {
      await _pedidoService.actualizarEstadoPedido(
          widget.pedido.id!, 'Pagado', '');
      await _cajaService.registrarTransaccion(
        transaccion_model.Transaction(
          id: '',
          pedidoId: widget.pedido.id,
          title: 'Pago de pedido ${widget.pedido.id}',
          amount: widget.pedido.total,
          paymentMethod: _metodoPago,
          date: DateTime.now(),
        ),
      );
      if (!mounted) return; // Verificar si el widget está montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago procesado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return; // Verificar si el widget está montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el pago: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Procesar Pago')),
      body: Column(
        children: [
          ResumenPago(pedido: widget.pedido),
          MetodoPagoSelector(
            metodoSeleccionado: _metodoPago,
            onMetodoSeleccionado: (metodo) {
              setState(() {
                _metodoPago = metodo;
              });
            },
          ),
          ElevatedButton(
            onPressed: _procesarPago,
            child: Text('Confirmar Pago'),
          ),
        ],
      ),
    );
  }
}
