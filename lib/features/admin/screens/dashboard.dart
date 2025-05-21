import 'package:flutter/material.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/services/gasto_service.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _totalVentas = 0.0;
  double _totalGastos = 0.0;
  bool _loading = true;

  final _pedidoFirestore = PedidoService().getFirestore();
  final _gastoFirestore = GastoService().getFirestore();

  @override
  void initState() {
    super.initState();
    _cargarTotales();
  }

  Future<void> _cargarTotales() async {
    setState(() {
      _loading = true;
    });
    try {
      // Total ventas: suma de todos los pedidos pagados
      final pedidos = await _pedidoFirestore
          .collection('pedidos')
          .where('estado', isEqualTo: 'Pagado')
          .get();
      double totalVentas = 0.0;
      for (var doc in pedidos.docs) {
        try {
          totalVentas += (doc.data()['total'] as num).toDouble();
        } catch (_) {}
      }

      // Total gastos: suma de todos los gastos
      final gastos = await _gastoFirestore.collection('gastos').get();
      double totalGastos = 0.0;
      for (var doc in gastos.docs) {
        try {
          totalGastos += (doc.data()['valor'] as num).toDouble();
        } catch (_) {}
      }

      setState(() {
        _totalVentas = totalVentas;
        _totalGastos = totalGastos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar totales: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;
    final isTablet = screenWidth >= 500 && screenWidth < 900;

    return AdminScaffoldLayout(
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.background,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_3.png',
                  width: isMobile
                      ? screenWidth * 0.7
                      : isTablet
                          ? screenWidth * 0.4
                          : screenWidth * 0.3,
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Bienvenidos!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _loading
                    ? CircularProgressIndicator()
                    : const SizedBox.shrink(),
                const SizedBox(height: 30),
                if (!_loading)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 4 : 16, vertical: 24),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 0,
                              maxWidth: isMobile
                                  ? screenWidth * 0.99
                                  : isTablet
                                      ? 600
                                      : 500,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.success,
                                    AppColors.success
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 28 : 30,
                                horizontal: isMobile ? 18 : 32,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: _BarTotalCard(
                                      title: "Total Ventas",
                                      value:
                                          "\$${_totalVentas.toStringAsFixed(1)}",
                                      icon: Icons.attach_money,
                                      color: Colors.white,
                                      isMobile: isMobile,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 0,
                              maxWidth: isMobile
                                  ? screenWidth * 0.99
                                  : isTablet
                                      ? 600
                                      : 500,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.danger, AppColors.primary],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.danger.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 28 : 30,
                                horizontal: isMobile ? 18 : 32,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: _BarTotalCard(
                                      title: "Total Gastos",
                                      value:
                                          "\$${_totalGastos.toStringAsFixed(1)}",
                                      icon: Icons.money_off,
                                      color: Colors.white,
                                      isMobile: isMobile,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarTotalCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isMobile;

  const _BarTotalCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? 0.85 * MediaQuery.of(context).size.width : 210,
      height: isMobile ? 110 : 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(isMobile ? 22 : 24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.18),
            child: Icon(icon, color: color, size: isMobile ? 32 : 32),
            radius: isMobile ? 28 : 28,
          ),
          const SizedBox(width: 18),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 34 : 24,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
