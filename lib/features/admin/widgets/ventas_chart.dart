import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VentasChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String chartType; // "bar" o "pie"

  const VentasChart({
    Key? key,
    required this.data,
    required this.labels,
    required this.chartType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: chartType == "bar" ? _buildBarChart() : _buildPieChart(),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: data
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    y: entry.value,
                    colors: [Colors.blue],
                    width: 16,
                  ),
                ],
              ),
            )
            .toList(),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) => labels[value.toInt()],
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
              ),
            )
            .toList(),
      ),
    );
  }
}
