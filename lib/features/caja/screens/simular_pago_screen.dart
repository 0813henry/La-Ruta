import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/features/caja/widgets/resumen_pago.dart';
import 'package:restaurante_app/features/caja/widgets/metodo_pago_selector.dart';
import 'package:restaurante_app/core/utils/pdf_generator.dart';
import 'package:url_launcher/url_launcher.dart';

class SimularPagoScreen extends StatefulWidget {
  final OrderModel pedido;

  const SimularPagoScreen({required this.pedido, super.key});

  @override
  State<SimularPagoScreen> createState() => _SimularPagoScreenState();
}

class _SimularPagoScreenState extends State<SimularPagoScreen> {
  String _metodoPago = 'Efectivo';

  String _generarResumenTexto(OrderModel pedido) {
    final detalles = pedido.items
        .map((item) =>
            '- ${item.nombre} x${item.cantidad} (\$${item.precio.toStringAsFixed(2)})\n  ${item.descripcion}')
        .join('\n');
    return '''
Resumen del Pedido:
ID del Pedido: ${pedido.id}
Cliente: ${pedido.cliente}
Estado: ${pedido.estado}
Tipo: ${pedido.tipo}
Total: \$${pedido.total.toStringAsFixed(2)}

Detalles:
$detalles
    ''';
  }

  Future<void> _enviarPorWhatsApp(OrderModel pedido) async {
    final resumenTexto = _generarResumenTexto(pedido);
    final whatsappUrl =
        'https://wa.me/?text=${Uri.encodeComponent(resumenTexto)}';

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simular Pago')),
      body: SingleChildScrollView(
        child: Column(
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
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _enviarPorWhatsApp(widget.pedido),
              icon: Icon(Icons.share),
              label: Text('Compartir por WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                // Aquí puedes usar tu generador de PDF para pedidos
                // Debes crear una función similar a generarPDFConfirmacion pero para pedidos
                await generarPDFPedido(widget.pedido, metodoPago: _metodoPago);
              },
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Generar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
