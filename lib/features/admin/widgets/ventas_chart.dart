import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VentasChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String chartType; // "bar" o "pie"

  const VentasChart({
    super.key,
    required this.data,
    required this.labels,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: chartType == "bar" ? _buildBarChart() : _buildPieChart(),
    );
  }

  Widget _buildBarChart() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: data.length * 50, // Espacio proporcional al número de barras
        child: BarChart(
          BarChartData(
            barGroups: data
                .asMap()
                .entries
                .map(
                  (entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Colors.blue,
                        width: 20,
                      ),
                    ],
                  ),
                )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta, // Cambio clave
                      child: Transform.rotate(
                        angle: -0.8,
                        child: Text(
                          labels[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: data
            .asMap()
            .entries
            .map(
              (entry) => PieChartSectionData(
                value: entry.value,
                title: labels[entry.key],
                color: Colors.primaries[entry.key % Colors.primaries.length],
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            )
            .toList(),
      ),
    );
  }
}
