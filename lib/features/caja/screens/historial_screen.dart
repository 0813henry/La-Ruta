import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/caja_service.dart';
import 'package:restaurante_app/core/widgets/venta_item.dart';
import 'package:restaurante_app/core/model/transaccion_model.dart'
    as transaccion_model; // Usar alias

class HistorialScreen extends StatelessWidget {
  final CajaService _cajaService = CajaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial de Ventas')),
      body: StreamBuilder<List<transaccion_model.Transaction>>(
        // Usar alias
        stream: _cajaService.obtenerTransacciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final transacciones = snapshot.data ?? [];
          if (transacciones.isEmpty) {
            return Center(child: Text('No hay transacciones registradas.'));
          }
          return ListView.builder(
            itemCount: transacciones.length,
            itemBuilder: (context, index) {
              final transaccion = transacciones[index];
              return VentaItem(transaccion: transaccion);
            },
          );
        },
      ),
    );
  }
}
