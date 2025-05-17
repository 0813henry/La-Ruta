import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- Agrega esto
import 'package:restaurante_app/core/services/gasto_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/features/admin/screens/reportes/widgets/balance_widget.dart';
import 'package:restaurante_app/features/admin/screens/reportes/widgets/perdidas_totales_widget.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';
import 'package:restaurante_app/features/admin/widgets/ventas_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final PedidoService _pedidoService = PedidoService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'Diario';
  DateTimeRange? _selectedDateRange;
  Map<String, int> _productosMasVendidos = {};
  Map<String, double> _ventasPorMesa = {};
  double _ganancias = 0.0;
  double _perdidasTotales = 0.0;
  double _balance = 0.0;
  int _selectedYear = DateTime.now().year;
  String _selectedWeekday = 'Todos';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null); // <-- Inicializa el locale
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

  // --- NUEVO: Agrupar ventas por mes ---
  Map<String, double> _ventasPorMes(List<Map<String, dynamic>> pedidos) {
    final Map<String, double> ventasMes = {};
    for (var pedido in pedidos) {
      final fecha = pedido['startTime'] as DateTime?;
      final total = (pedido['total'] as num?)?.toDouble() ?? 0.0;
      if (fecha != null && fecha.year == _selectedYear) {
        // Asegura que el locale esté inicializado
        final mes = DateFormat('MMMM', 'es_ES').format(fecha);
        ventasMes[mes] = (ventasMes[mes] ?? 0) + total;
      }
    }
    return ventasMes;
  }

  // --- NUEVO: Agrupar ventas por día de la semana ---
  Map<String, double> _ventasPorDiaSemana(List<Map<String, dynamic>> pedidos) {
    final Map<String, double> ventasDia = {};
    for (var pedido in pedidos) {
      final fecha = pedido['startTime'] as DateTime?;
      final total = (pedido['total'] as num?)?.toDouble() ?? 0.0;
      if (fecha != null &&
          (_selectedWeekday == 'Todos' ||
              DateFormat('EEEE', 'es_ES').format(fecha) == _selectedWeekday)) {
        final dia = DateFormat('EEEE', 'es_ES').format(fecha);
        ventasDia[dia] = (ventasDia[dia] ?? 0) + total;
      }
    }
    return ventasDia;
  }

  // --- NUEVO: Obtener todos los pedidos pagados para análisis ---
  Future<List<Map<String, dynamic>>> _obtenerPedidosPagados() async {
    final snapshot = await _firestore
        .collection('pedidos')
        .where('estado', isEqualTo: 'Pagado')
        .get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          DateTime? fecha;
          try {
            fecha = data['startTime'] != null
                ? DateTime.parse(data['startTime'])
                : null;
          } catch (_) {}
          return {
            ...data,
            'startTime': fecha,
          };
        })
        .where((pedido) => pedido['startTime'] != null)
        .toList();
  }

  // --- NUEVO: Widget para seleccionar año ---
  Widget _buildYearDropdown(List<int> years) {
    return DropdownButton<int>(
      value: _selectedYear,
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedYear = value);
      },
    );
  }

  // --- NUEVO: Widget para seleccionar día de la semana ---
  Widget _buildWeekdayDropdown(List<String> dias) {
    return DropdownButton<String>(
      value: _selectedWeekday,
      items:
          dias.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedWeekday = value);
      },
    );
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _obtenerPedidosPagados(),
        builder: (context, snapshot) {
          final pedidosPagados = snapshot.data ?? [];
          // Ventas por tipo de pedido (Local, Domicilio, VIP) y estado "Pagado"
          Map<String, double> ventasPorTipo = {
            'Local': 0,
            'Domicilio': 0,
            'VIP': 0
          };
          Map<String, int> cantidadPorTipo = {
            'Local': 0,
            'Domicilio': 0,
            'VIP': 0
          };
          for (var pedido in pedidosPagados) {
            final tipo = (pedido['tipo'] ?? '').toString().toLowerCase();
            final estado = (pedido['estado'] ?? '').toString().toLowerCase();
            if (estado == 'pagado') {
              final total = (pedido['total'] as num?)?.toDouble() ?? 0.0;
              if (tipo == 'local' || tipo == 'domicilio' || tipo == 'vip') {
                final tipoKey = tipo[0].toUpperCase() + tipo.substring(1);
                ventasPorTipo[tipoKey] = (ventasPorTipo[tipoKey] ?? 0) + total;
                cantidadPorTipo[tipoKey] = (cantidadPorTipo[tipoKey] ?? 0) + 1;
              }
            }
          }
          final tipos = ['Local', 'Domicilio', 'VIP'];
          final totalVentas = ventasPorTipo.values.fold(0.0, (a, b) => a + b);
          final totalCantidad = cantidadPorTipo.values.fold(0, (a, b) => a + b);

          // Obtener años únicos para el filtro
          final years = pedidosPagados
              .map((p) => (p['startTime'] as DateTime?)?.year)
              .whereType<int>()
              .toSet()
              .toList()
            ..sort();
          if (years.isEmpty) years.add(DateTime.now().year);

          // Días de la semana en español
          final diasSemana = [
            'Todos',
            'lunes',
            'martes',
            'miércoles',
            'jueves',
            'viernes',
            'sábado',
            'domingo'
          ];

          // Ventas por mes y por día de semana
          final ventasMes = _ventasPorMes(pedidosPagados);
          final ventasDiaSemana = _ventasPorDiaSemana(pedidosPagados);

          return SingleChildScrollView(
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
                  // KPIs
                  if (_selectedDateRange != null)
                    GananciasKPIWidget(
                      ganancias: _ganancias,
                      selectedDateRange: _selectedDateRange!,
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
                      ProductoMasVendidoWidget(
                          productosMasVendidos: _productosMasVendidos),
                      VentasPorTipoWidget(
                        ventasPorTipo: ventasPorTipo,
                        cantidadPorTipo: cantidadPorTipo,
                        tipos: tipos,
                      ),
                      VentasPorMesWidget(
                        ventasMes: ventasMes,
                        years: years,
                        buildYearDropdown: _buildYearDropdown,
                      ),
                      VentasPorDiaSemanaWidget(
                        ventasDiaSemana: ventasDiaSemana,
                        diasSemana: diasSemana,
                        buildWeekdayDropdown: _buildWeekdayDropdown,
                      ),
                    ],
                  ),
                  // --- NUEVO: Resumen de ventas por tipo de pedido ---
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
                            'Ventas por Tipo de Pedido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: tipos.map((tipo) {
                              return Column(
                                children: [
                                  Text(
                                    tipo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${cantidadPorTipo[tipo] ?? 0} ventas',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '\$${ventasPorTipo[tipo]!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Total ventas: $totalCantidad',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Total: \$${totalVentas.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.green[800],
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
        },
      ),
    );
  }
}

// --- Widgets separados para KPIs y gráficos ---

class GananciasKPIWidget extends StatelessWidget {
  final double ganancias;
  final DateTimeRange selectedDateRange;

  const GananciasKPIWidget({
    super.key,
    required this.ganancias,
    required this.selectedDateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    '\$${ganancias.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(selectedDateRange.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange.end)}',
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
    );
  }
}

class ProductoMasVendidoWidget extends StatelessWidget {
  final Map<String, int> productosMasVendidos;

  const ProductoMasVendidoWidget(
      {super.key, required this.productosMasVendidos});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            if (productosMasVendidos.isNotEmpty)
              Expanded(
                child: VentasChart(
                  data: productosMasVendidos.values
                      .map((e) => e.toDouble())
                      .toList(),
                  labels: productosMasVendidos.keys.toList(),
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
    );
  }
}

class VentasPorTipoWidget extends StatelessWidget {
  final Map<String, double> ventasPorTipo;
  final Map<String, int> cantidadPorTipo;
  final List<String> tipos;

  const VentasPorTipoWidget({
    super.key,
    required this.ventasPorTipo,
    required this.cantidadPorTipo,
    required this.tipos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
              'Ventas por Tipo de Pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (ventasPorTipo.isNotEmpty)
              Expanded(
                child: ListView(
                  children: tipos
                      .where((t) => ventasPorTipo.containsKey(t))
                      .map((tipo) => Card(
                            color: Colors.grey[100],
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: Icon(
                                tipo == 'Local'
                                    ? Icons.store
                                    : tipo == 'VIP'
                                        ? Icons.star
                                        : tipo == 'Domicilio'
                                            ? Icons.delivery_dining
                                            : Icons.help_outline,
                                color: tipo == 'Local'
                                    ? Colors.green
                                    : tipo == 'VIP'
                                        ? Colors.amber[800]
                                        : tipo == 'Domicilio'
                                            ? Colors.blue
                                            : Colors.grey,
                              ),
                              title: Text(
                                tipo,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Total: \$${ventasPorTipo[tipo]!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${cantidadPorTipo[tipo] ?? 0} ventas',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              )
            else
              Center(
                child: Text('No hay datos disponibles.'),
              ),
          ],
        ),
      ),
    );
  }
}

class VentasPorMesWidget extends StatelessWidget {
  final Map<String, double> ventasMes;
  final List<int> years;
  final Widget Function(List<int>) buildYearDropdown;

  const VentasPorMesWidget({
    super.key,
    required this.ventasMes,
    required this.years,
    required this.buildYearDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Ventas por Mes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                buildYearDropdown(years),
              ],
            ),
            SizedBox(height: 16),
            if (ventasMes.isNotEmpty)
              Expanded(
                child: ListView(
                  children: ventasMes.entries
                      .map((entry) => ListTile(
                            leading:
                                Icon(Icons.calendar_today, color: Colors.blue),
                            title: Text(
                              entry.key[0].toUpperCase() +
                                  entry.key.substring(1),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                ),
              )
            else
              Center(
                child: Text('No hay datos disponibles.'),
              ),
          ],
        ),
      ),
    );
  }
}

class VentasPorDiaSemanaWidget extends StatelessWidget {
  final Map<String, double> ventasDiaSemana;
  final List<String> diasSemana;
  final Widget Function(List<String>) buildWeekdayDropdown;

  const VentasPorDiaSemanaWidget({
    super.key,
    required this.ventasDiaSemana,
    required this.diasSemana,
    required this.buildWeekdayDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Ventas por Día de Semana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                buildWeekdayDropdown(diasSemana),
              ],
            ),
            SizedBox(height: 16),
            if (ventasDiaSemana.isNotEmpty)
              Expanded(
                child: ListView(
                  children: ventasDiaSemana.entries
                      .map((entry) => ListTile(
                            leading:
                                Icon(Icons.today, color: Colors.deepPurple),
                            title: Text(
                              entry.key[0].toUpperCase() +
                                  entry.key.substring(1),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                ),
              )
            else
              Center(
                child: Text('No hay datos disponibles.'),
              ),
          ],
        ),
      ),
    );
  }
}
