import 'package:flutter/material.dart';
import '../../../../core/widgets/grafico_ventas.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
      ),
      body: Column(
        children: [
          Text('Reporte de Ventas Diarias'),
          SalesChart(), // Update SalesChart to use fl_chart
          Text('Reporte de Ventas Semanales'),
          SalesChart(), // Update SalesChart to use fl_chart
          Text('Reporte de Ventas Mensuales'),
          SalesChart(), // Update SalesChart to use fl_chart
          Text('Productos Más Vendidos'),
          SalesChart(), // Update SalesChart to use fl_chart
        ],
      ),
    );
  }
}
