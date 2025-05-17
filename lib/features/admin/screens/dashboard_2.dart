import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen2 extends StatelessWidget {
  const DashboardScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Control')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filtros
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildDropdown('Trimestre Fiscal'),
                _buildDropdown('Región'),
                _buildDropdown('Gerente de Reservas'),
                _buildDropdown('Responsable de Reservas'),
              ],
            ),
            const SizedBox(height: 16),

            // Tarjetas de KPIs
            _buildKPI("Reservas de Campo", "\$159.4M", 40),
            _buildKPI("Crecimiento de Pipeline", "\$114.4M", 40),
            _buildKPI("Pipeline Abierto No Ponderado", "\$207.4M", 40),
            _buildKPI("Pipeline Abierto Ponderado", "\$127.4M", 40),

            const SizedBox(height: 16),

            // Donut Chart
            _buildDonutChartCard(),

            const SizedBox(height: 16),

            // Bar Chart
            _buildSalesPipelineChart(),

            const SizedBox(height: 16),

            // Tabla
            _buildProductLineTable(),

            const SizedBox(height: 16),

            // Line Charts
            _buildLineChart(context, "Progreso de Reservas"),
            const SizedBox(height: 16),
            _buildLineChart(context, "Creación de Pipeline"),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return DropdownButtonFormField<String>(
      value: null,
      hint: Text(label),
      items: ["Q1", "Q2", "Q3", "Q4"]
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildKPI(String title, String value, int percentage) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle:
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.trending_up, color: Colors.green),
            Text('$percentage%', style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChartCard() {
    final data = [143.1, 38.2, 129.9, 78.1];
    final labels = [
      'Renovación',
      'Venta Cruzada',
      'Adicionales',
      'Adquisición'
    ];

    return Card(
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: List.generate(data.length, (i) {
              final color = Colors.primaries[i % Colors.primaries.length];
              return PieChartSectionData(
                color: color,
                value: data[i],
                title: '${labels[i]}\n\$${data[i]}M',
                radius: 50,
                titleStyle: const TextStyle(fontSize: 10),
              );
            }),
            centerSpaceRadius: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildSalesPipelineChart() {
    final labels = [
      'Pendiente',
      'Propuesta',
      'Prospecto',
      'Comprometido',
      'Construcción',
      'Recomendación',
      'Cierre',
      'Negociación',
      'Cerrado',
      'Ganado'
    ];
    final values = [3, 20, 1289, 12100, 5882, 388, 4563, 281, 5078, 5930];

    return Card(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: List.generate(values.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i].toDouble(),
                    color: Colors.blueAccent,
                    width: 10,
                  )
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    return Text(
                      index < labels.length ? labels[index] : '',
                      style: const TextStyle(fontSize: 8),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(),
              topTitles: AxisTitles(),
            ),
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildProductLineTable() {
    return Card(
      child: Column(
        children: [
          const ListTile(title: Text("Resumen de Líneas de Producto")),
          DataTable(
            columns: const [
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Adquisición')),
              DataColumn(label: Text('Adicionales')),
              DataColumn(label: Text('Venta Cruzada')),
              DataColumn(label: Text('Renovaciones')),
              DataColumn(label: Text('Total')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text("Contratación")),
                DataCell(Text("\$2M")),
                DataCell(Text("\$4M")),
                DataCell(Text("\$24M")),
                DataCell(Text("\$1M")),
                DataCell(Text("\$31M")),
              ]),
              DataRow(cells: [
                DataCell(Text("Capacitación")),
                DataCell(Text("\$1M")),
                DataCell(Text("\$5M")),
                DataCell(Text("\$32M")),
                DataCell(Text("\$2M")),
                DataCell(Text("\$40M")),
              ]),
              DataRow(cells: [
                DataCell(Text("Compromiso")),
                DataCell(Text("\$1M")),
                DataCell(Text("\$3M")),
                DataCell(Text("\$20M")),
                DataCell(Text("\$1M")),
                DataCell(Text("\$25M")),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, String title) {
    final dataPoints = [10, 20, 25, 30, 28, 35, 40, 45];
    final width = MediaQuery.of(context).size.width;

    return Card(
      child: Column(
        children: [
          ListTile(title: Text(title)),
          SizedBox(
            height: 200,
            width: width,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: List.generate(
                      dataPoints.length,
                      (i) => FlSpot(i.toDouble(), dataPoints[i].toDouble()),
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    color: Colors.blueAccent,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: false),
                  ),
                ],
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) =>
                          Text("7/${(value.toInt() + 1).toString()}"),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
