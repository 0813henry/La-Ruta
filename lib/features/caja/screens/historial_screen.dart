import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/services/notification_service.dart';
import 'package:restaurante_app/features/caja/widgets/resumen_pago.dart';
import 'package:restaurante_app/core/utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/menu_lateral_caja.dart';

class HistorialScreen extends StatefulWidget {
  final PedidoService _pedidoService = PedidoService();

  HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  List<OrderModel> _allPedidos = [];
  List<OrderModel> _filteredPedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    NotificationService().escucharNotificacionesCocina((mesaId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesa $mesaId lista para pagado')),
      );
    });
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    setState(() => _isLoading = true);
    widget._pedidoService.obtenerPedidosPorEstado('Pagado').listen((pedidos) {
      setState(() {
        _allPedidos = pedidos;
        _applyFilters();
        _isLoading = false;
      });
    });
  }

  void _applyFilters() {
    List<OrderModel> pedidos = List.from(_allPedidos);

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      pedidos = pedidos
          .where((p) =>
              p.cliente.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filtro por rango de fechas
    if (_selectedDateRange != null) {
      pedidos = pedidos.where((p) {
        final date = p.startTime ?? DateTime.now();
        return date.isAfter(
                _selectedDateRange!.start.subtract(Duration(days: 1))) &&
            date.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _filteredPedidos = pedidos;
    });
  }

  Color _colorTipoPedido(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'domicilio':
        return AppColors.domicilio;
      case 'vip':
        return AppColors.vip;
      case 'local':
        return AppColors.principal;
      default:
        return AppColors.coolGray;
    }
  }

  Future<void> _compartirPDF(OrderModel pedido, String metodoPago) async {
    final pdf =
        await generarPDFPedido(pedido, metodoPago: metodoPago, returnPdf: true);
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'pedido_${pedido.id}.pdf');
  }

  Future<void> _descargarPDF(OrderModel pedido, String metodoPago) async {
    final pdf =
        await generarPDFPedido(pedido, metodoPago: metodoPago, returnPdf: true);
    final bytes = await pdf.save();

    // Mostrar el PDF usando Printing.layoutPdf (como generarPDFConfirmacion)
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'pedido_${pedido.id}.pdf',
    );
  }

  Future<void> _enviarPorWhatsApp(OrderModel pedido) async {
    final pdf =
        await generarPDFPedido(pedido, metodoPago: 'Pagado', returnPdf: true);
    final bytes = await pdf.save();
    // Printing.sharePdf abre el diálogo de compartir, WhatsApp aparecerá si está instalado
    await Printing.sharePdf(bytes: bytes, filename: 'pedido_${pedido.id}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Ventas')),
      drawer: MenuLateralCaja(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por cliente',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.date_range),
                    label: Text(_selectedDateRange == null
                        ? 'Filtrar por fecha'
                        : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'),
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                      );
                      if (range != null) {
                        setState(() {
                          _selectedDateRange = range;
                          _applyFilters();
                        });
                      }
                    },
                  ),
                ),
                if (_selectedDateRange != null)
                  IconButton(
                    icon: Icon(Icons.clear),
                    tooltip: 'Limpiar filtro de fecha',
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                        _applyFilters();
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredPedidos.isEmpty
                    ? Center(child: Text('No hay pedidos con estado "Pagado".'))
                    : ListView.builder(
                        itemCount: _filteredPedidos.length,
                        itemBuilder: (context, index) {
                          final pedido = _filteredPedidos[index];
                          final tipoColor = _colorTipoPedido(pedido.tipo);
                          final fecha = pedido.startTime != null
                              ? DateFormat('dd/MM/yyyy HH:mm')
                                  .format(pedido.startTime!)
                              : '';
                          double totalGeneral = pedido.total;
                          if (pedido.divisiones != null &&
                              pedido.divisiones!.isNotEmpty) {
                            double totalDiv = 0.0;
                            pedido.divisiones!.forEach((_, items) {
                              for (var item in items) {
                                final adicionalesTotal = item.adicionales.fold(
                                  0.0,
                                  (sum, adicional) =>
                                      sum + (adicional['price'] as double),
                                );
                                totalDiv += (item.precio + adicionalesTotal) *
                                    item.cantidad;
                              }
                            });
                            totalGeneral += totalDiv;
                          }
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            elevation: 4,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: tipoColor,
                                child:
                                    Icon(Icons.fastfood, color: Colors.white),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pedido.cliente,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: tipoColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      pedido.tipo.toUpperCase(),
                                      style: TextStyle(
                                        color: tipoColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: $fecha'),
                                  Text(
                                    'Total: \$${totalGeneral.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 'pdf') {
                                    await _descargarPDF(pedido, 'Pagado');
                                  } else if (value == 'whatsapp') {
                                    await _enviarPorWhatsApp(pedido);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'pdf',
                                    child: Row(
                                      children: [
                                        Icon(Icons.download,
                                            color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Descargar PDF'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'whatsapp',
                                    child: Row(
                                      children: [
                                        Icon(Icons.share, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Enviar PDF por WhatsApp'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: SingleChildScrollView(
                                      child: ResumenPago(pedido: pedido),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cerrar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
