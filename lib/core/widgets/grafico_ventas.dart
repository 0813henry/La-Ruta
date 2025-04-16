// Gráficos para mostrar reportes de ventas.
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 5),
                FlSpot(1, 25),
                FlSpot(2, 100),
                FlSpot(3, 75),
                FlSpot(4, 55),
                FlSpot(5, 85),
                FlSpot(6, 45),
              ],
              isCurved: true,
              colors: [Colors.blue],
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true),
            bottomTitles: SideTitles(showTitles: true),
          ),
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Gráfico de Ventas')),
      body: SalesChart(),
    ),
  ));
}
