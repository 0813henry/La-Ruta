import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurante_app/core/services/gasto_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/features/admin/screens/reportes/widgets/balance_widget.dart';
import 'package:restaurante_app/features/admin/screens/reportes/widgets/perdidas_totales_widget.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';
import '../../widgets/ventas_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final PedidoService _pedidoService = PedidoService();
  String _selectedFilter = 'Diario';
  DateTimeRange? _selectedDateRange;
  Map<String, int> _productosMasVendidos = {};
  Map<String, double> _ventasPorMesa = {};
  double _ganancias = 0.0;
  double _perdidasTotales = 0.0;
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final productos = await _pedidoService.obtenerProductosMasVendidos();
      final ventas = await _pedidoService.obtenerVentasPorMesa();
      setState(() {
        _productosMasVendidos = productos.isNotEmpty ? productos : {};
        _ventasPorMesa = ventas.isNotEmpty ? ventas : {};
      });
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<void> _calcularGanancias() async {
    if (_selectedDateRange != null) {
      try {
        final ganancias = await _pedidoService.obtenerGananciasPorEstadoYPago(
          _selectedDateRange!.start,
          _selectedDateRange!.end,
        );
        setState(() {
          _ganancias = ganancias;
        });
      } catch (e) {
        debugPrint('Error al calcular ganancias: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular ganancias: $e')),
        );
      }
    }
  }

  Future<void> _calcularPerdidasTotalesYBalance() async {
    if (_selectedDateRange != null) {
      try {
        final gastos = await GastoService().obtenerGastosPorRango(
          _selectedDateRange!.start,
          _selectedDateRange!.end,
        );
        final perdidasTotales =
            gastos.fold(0.0, (sum, gasto) => sum + gasto.valor);
        setState(() {
          _perdidasTotales = perdidasTotales;
          _balance = _ganancias - _perdidasTotales;
        });
      } catch (e) {
        debugPrint('Error al calcular pérdidas y balance: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular pérdidas y balance: $e')),
        );
      }
    }
  }

  void _actualizarFiltro(String filtro) {
    setState(() {
      _selectedFilter = filtro;
      final now = DateTime.now();
      if (filtro == 'Diario') {
        _selectedDateRange = DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      } else if (filtro == 'Semanal') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        _selectedDateRange = DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: DateTime(
              endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
        );
      } else if (filtro == 'Mensual') {
        _selectedDateRange = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      }
    });
    _calcularGanancias();
    _calcularPerdidasTotalesYBalance();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return AdminScaffoldLayout(
      title: Row(
        children: [
          const Expanded(child: Text('Reportes de Ventas')),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtros
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: _selectedFilter,
                        items: ['Diario', 'Semanal', 'Mensual']
                            .map((filter) => DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _actualizarFiltro(value);
                          }
                        },
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (range != null) {
                            setState(() {
                              _selectedDateRange = range;
                            });
                            await _calcularGanancias();
                            await _calcularPerdidasTotalesYBalance();
                          }
                        },
                        icon: Icon(Icons.date_range),
                        label: Text('Seleccionar Rango'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Ganancias
              if (_selectedDateRange != null)
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, size: 48, color: Colors.green),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ganancias Totales',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '\$${_ganancias.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 16),
              PerdidasTotalesWidget(perdidasTotales: _perdidasTotales),
              SizedBox(height: 16),
              BalanceWidget(balance: _balance),
              SizedBox(height: 16),
              // Gráficos
              GridView.count(
                crossAxisCount: isSmallScreen ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  // Producto más vendido
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Producto Más Vendido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          if (_productosMasVendidos.isNotEmpty)
                            Expanded(
                              child: VentasChart(
                                data: _productosMasVendidos.values
                                    .map((e) => e.toDouble())
                                    .toList(),
                                labels: _productosMasVendidos.keys.toList(),
                                chartType: 'bar',
                              ),
                            )
                          else
                            Center(
                              child: Text('No hay datos disponibles.'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Mesa con más ventas
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mesa con Más Ventas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          if (_ventasPorMesa.isNotEmpty)
                            Expanded(
                              child: VentasChart(
                                data: _ventasPorMesa.values.toList(),
                                labels: _ventasPorMesa.keys.toList(),
                                chartType: 'pie',
                              ),
                            )
                          else
                            Center(
                              child: Text('No hay datos disponibles.'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
