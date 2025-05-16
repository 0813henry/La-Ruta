import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:restaurante_app/core/model/gasto_model.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:http/http.dart' as http;

Future<void> generarPDFConfirmacion(Gasto gasto) async {
  final pdf = pw.Document();
  Uint8List? imageBytes;

  // ✅ Cargar logo desde assets de forma segura
  final ByteData logoData = await rootBundle.load('assets/images/logo_2.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();

  // ✅ Descargar imagen del gasto si existe
  if (gasto.imagenUrl != null && gasto.imagenUrl!.isNotEmpty) {
    try {
      final response = await http.get(Uri.parse(gasto.imagenUrl!));
      if (response.statusCode == 200) {
        imageBytes = response.bodyBytes;
      }
    } catch (_) {}
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Confirmación de Gasto',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Image(pw.MemoryImage(logoBytes), height: 50),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('ID de transacción: G-${gasto.id}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            pw.SizedBox(height: 20),
            if (imageBytes != null)
              pw.Center(
                child: pw.Image(pw.MemoryImage(imageBytes),
                    height: 80, fit: pw.BoxFit.contain),
              ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Descripción', 'Fecha', 'Valor'],
              data: [
                [
                  gasto.descripcion,
                  '${gasto.fecha.day}/${gasto.fecha.month}/${gasto.fecha.year} - ${gasto.fecha.hour}:${gasto.fecha.minute.toString().padLeft(2, '0')}',
                  '- \$${gasto.valor.toStringAsFixed(2)}'
                ]
              ],
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
              },
              cellStyle: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 30),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'Este comprobante certifica la creación del gasto en la plataforma RestauranteApp.',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'La Ruta © ${DateTime.now().year}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            )
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

Future<pw.Document> generarPDFPedido(OrderModel pedido,
    {String? metodoPago, bool returnPdf = false}) async {
  final pdf = pw.Document();

  final ByteData logoData = await rootBundle.load('assets/images/logo_2.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();

  double divisionSubtotal(List<OrderItem> items) {
    double subtotal = 0.0;
    for (var item in items) {
      final adicionalesTotal = item.adicionales.fold(
        0.0,
        (sum, adicional) => sum + (adicional['price'] as double),
      );
      subtotal += (item.precio + adicionalesTotal) * item.cantidad;
    }
    return subtotal;
  }

  double totalGeneral(OrderModel pedido) {
    double total = divisionSubtotal(pedido.items);
    if (pedido.divisiones != null && pedido.divisiones!.isNotEmpty) {
      pedido.divisiones!.forEach((_, items) {
        total += divisionSubtotal(items);
      });
    }
    return total;
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Factura de Pedido',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.Image(pw.MemoryImage(logoBytes), height: 50),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('ID Pedido: ${pedido.id}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            pw.Text('Cliente: ${pedido.cliente}'),
            pw.Text('Estado: ${pedido.estado}'),
            pw.Text('Tipo: ${pedido.tipo}'),
            if (metodoPago != null) pw.Text('Método de Pago: $metodoPago'),
            pw.SizedBox(height: 20),
            pw.Text('Productos principales:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...pedido.items.map((item) {
              final adicionalesTotal = item.adicionales.fold(
                0.0,
                (sum, adicional) => sum + (adicional['price'] as double),
              );
              final itemTotal =
                  (item.precio + adicionalesTotal) * item.cantidad;
              return pw.Row(
                children: [
                  pw.Expanded(
                      child: pw.Text('${item.nombre} x${item.cantidad}')),
                  pw.Text('\$${itemTotal.toStringAsFixed(2)}'),
                ],
              );
            }),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Subtotal: \$${divisionSubtotal(pedido.items).toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            if (pedido.divisiones != null && pedido.divisiones!.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('Divisiones:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...pedido.divisiones!.entries.map((entry) {
                final division = entry.key;
                final productos = entry.value;
                final subtotal = divisionSubtotal(productos);
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('División: $division',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ...productos.map((item) {
                          final adicionalesTotal = item.adicionales.fold(
                            0.0,
                            (sum, adicional) =>
                                sum + (adicional['price'] as double),
                          );
                          final itemTotal =
                              (item.precio + adicionalesTotal) * item.cantidad;
                          return pw.Row(
                            children: [
                              pw.Expanded(
                                  child: pw.Text(
                                      '${item.nombre} x${item.cantidad}')),
                              pw.Text('\$${itemTotal.toStringAsFixed(2)}'),
                            ],
                          );
                        }),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'TOTAL GENERAL: \$${totalGeneral(pedido).toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                    color: PdfColors.green800,
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'La Ruta © ${DateTime.now().year}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            )
          ],
        );
      },
    ),
  );

  if (returnPdf) {
    return pdf;
  } else {
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
    return pdf;
  }
}
