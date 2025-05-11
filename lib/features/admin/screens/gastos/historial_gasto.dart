import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/gasto_service.dart';
import 'package:restaurante_app/core/model/gasto_model.dart';
import 'widgets/menu_lateral_gastos.dart';
import 'widgets/detalle_gasto.dart';

class HistorialGastoScreen extends StatelessWidget {
  final GastoService _gastoService = GastoService();

  HistorialGastoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Gastos'),
        backgroundColor: Colors.teal,
      ),
      drawer: SidebarMenuGastos(),
      body: StreamBuilder<List<Gasto>>(
        stream: _gastoService.obtenerGastos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los gastos.'));
          }
          final gastos = snapshot.data ?? [];
          if (gastos.isEmpty) {
            return Center(child: Text('No hay gastos registrados.'));
          }
          return ListView.builder(
            itemCount: gastos.length,
            itemBuilder: (context, index) {
              final gasto = gastos[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: gasto.imagenUrl != null
                      ? Image.network(
                          gasto.imagenUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.money_off, size: 50, color: Colors.teal),
                  title: Text(gasto.descripcion),
                  subtitle: Text(
                      'Valor: \$${gasto.valor.toStringAsFixed(2)}\nFecha: ${gasto.fecha.toLocal()}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleGastoWidget(gasto: gasto),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
