import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

class PdfGenerator {
  Future<void> generateInvoice(String filePath, Map<String, dynamic> invoiceData) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Factura', style: pw.TextStyle(font: ttf, fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Cliente: ${invoiceData['customerName']}', style: pw.TextStyle(font: ttf, fontSize: 18)),
              pw.Text('Fecha: ${invoiceData['date']}', style: pw.TextStyle(font: ttf, fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Producto', 'Cantidad', 'Precio', 'Total'],
                  ...invoiceData['items'].map<List<String>>((item) => [
                        item['product'],
                        item['quantity'].toString(),
                        item['price'].toString(),
                        (item['quantity'] * item['price']).toString()
                      ])
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total: ${invoiceData['total']}', style: pw.TextStyle(font: ttf, fontSize: 18)),
            ],
          );
        },
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
  }
}