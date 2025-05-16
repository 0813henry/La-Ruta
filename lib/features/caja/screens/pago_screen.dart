import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/caja_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/model/transaccion_model.dart'
    as transaccion_model;
import 'package:restaurante_app/features/caja/widgets/metodo_pago_selector.dart';
import 'package:restaurante_app/features/caja/widgets/resumen_pago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:restaurante_app/core/utils/pdf_generator.dart';
import 'package:printing/printing.dart';

class PagoScreen extends StatefulWidget {
  final OrderModel pedido;

  const PagoScreen({required this.pedido, super.key});

  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final CajaService _cajaService = CajaService();
  final PedidoService _pedidoService = PedidoService();
  String _metodoPago = 'Efectivo';
  bool _isProcessing = false;

  Future<void> _procesarPago() async {
    setState(() => _isProcessing = true);
    try {
      await _pedidoService.actualizarEstadoPedido(
          widget.pedido.id, 'Pagado', '');
      await _cajaService.registrarTransaccion(
        transaccion_model.Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          pedidoId: widget.pedido.id,
          title: 'Pago de pedido ${widget.pedido.id}',
          amount: widget.pedido.total,
          paymentMethod: _metodoPago,
          date: DateTime.now(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pago procesado exitosamente ($_metodoPago)')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el pago: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _descargarYCompartirPDF() async {
    final pdf = await generarPDFPedido(widget.pedido,
        metodoPago: _metodoPago, returnPdf: true);
    final bytes = await pdf.save();
    await Printing.sharePdf(
        bytes: bytes, filename: 'pedido_${widget.pedido.id}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Procesar Pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ResumenPago(pedido: widget.pedido),
            SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    MetodoPagoSelector(
                      metodoSeleccionado: _metodoPago,
                      onMetodoSeleccionado: (metodo) {
                        setState(() {
                          _metodoPago = metodo;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    _isProcessing
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton.icon(
                            onPressed: _procesarPago,
                            icon: Icon(Icons.check_circle),
                            label: Text('Confirmar Pago ($_metodoPago)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 48),
                              textStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _descargarYCompartirPDF,
                            icon: Icon(Icons.picture_as_pdf),
                            label: Text('Compartir PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _descargarYCompartirPDF();
                            },
                            icon: Icon(Icons.share),
                            label: Text('Enviar por WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
