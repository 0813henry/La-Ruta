import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/caja_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/model/transaccion_model.dart'
    as transaccion_model;
import 'package:restaurante_app/features/caja/widgets/metodo_pago_selector.dart';
import 'package:restaurante_app/features/caja/widgets/resumen_pago.dart';
import 'package:url_launcher/url_launcher.dart';

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago procesado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
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
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Simulate payment
              try {
                await _pedidoService.actualizarEstadoPedido(
                    widget.pedido.id!, 'Pagado', '');
                await _cajaService.registrarTransaccion(
                  transaccion_model.Transaction(
                    id: '',
                    pedidoId: widget.pedido.id,
                    title: 'Pago Simulado de pedido ${widget.pedido.id}',
                    amount: widget.pedido.total,
                    paymentMethod: 'Efectivo',
                    date: DateTime.now(),
                  ),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pago simulado exitosamente')),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al simular el pago: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Simular Pago en Efectivo'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final whatsappUrl =
                  'https://wa.me/?text=Cuenta%20de%20pedido%20${widget.pedido.id}%3A%20\$${widget.pedido.total.toStringAsFixed(2)}';
              if (await canLaunch(whatsappUrl)) {
                await launch(whatsappUrl);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No se pudo abrir WhatsApp')),
                );
              }
            },
            child: Text('Enviar Cuenta por WhatsApp'),
          ),
        ],
      ),
    );
  }
}
