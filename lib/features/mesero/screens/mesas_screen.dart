import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/constants/app_styles.dart';
import 'package:restaurante_app/core/model/mesa_model.dart';
import 'package:restaurante_app/core/services/mesa_service.dart';
import '../widgets/mesa_grid.dart';
import '../widgets/menu_lateral_mesero.dart';
import '../../../routes/app_routes.dart';

class MesasScreen extends StatelessWidget {
  final MesaService _mesaService = MesaService();

  Future<void> _inicializarMesas() async {
    final mesas = await _mesaService.obtenerMesasUnaVez();
    if (mesas.isEmpty) {
      final mesasIniciales = [
        for (int i = 1; i <= 8; i++)
          Mesa(
            id: 'P$i-${DateTime.now().millisecondsSinceEpoch}', // Ensure a unique ID
            nombre: 'Mesa Principal $i',
            estado: 'Libre',
            capacidad: 4,
            tipo: 'Principal',
          ),
        for (int i = 1; i <= 4; i++)
          Mesa(
            id: 'V$i-${DateTime.now().millisecondsSinceEpoch}', // Ensure a unique ID
            nombre: 'Mesa VIP $i',
            estado: 'Libre',
            capacidad: 6,
            tipo: 'VIP',
          ),
      ];
      for (var mesa in mesasIniciales) {
        await _mesaService.agregarMesa(mesa);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Mesas', style: AppStyles.heading),
        backgroundColor: AppColors.secondary,
      ),
      drawer: MenuLateralMesero(),
      body: FutureBuilder(
        future: _inicializarMesas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MesaGrid(
                  onMesaTap: (mesa) {
                    if (mesa.id.isEmpty) {
                      throw Exception(
                          'El ID de la mesa no puede estar vacío.'); // Debugging check
                    }

                    Navigator.pushNamed(
                      context,
                      AppRoutes.mesaDetail,
                      arguments: {
                        'mesaId': mesa.id,
                        'estado': mesa.estado,
                        'nombre': mesa.nombre
                      },
                    );
                  },
                  isWideScreen: constraints.maxWidth > 600,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: Icon(Icons.add, color: AppColors.textPrimary),
        onPressed: () async {
          String? inputMesaName;
          int? inputCapacidad;
          String? inputTipo = 'Principal';

          final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Agregar Mesa'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Nombre de la Mesa (opcional)'),
                      onChanged: (value) => inputMesaName = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Capacidad'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          inputCapacidad = int.tryParse(value),
                    ),
                    DropdownButtonFormField<String>(
                      value: inputTipo,
                      decoration: InputDecoration(labelText: 'Tipo de Mesa'),
                      items: ['Principal', 'VIP', 'Domicilio']
                          .map((tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              ))
                          .toList(),
                      onChanged: (value) => inputTipo = value,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Agregar'),
                  ),
                ],
              );
            },
          );

          if (result == true) {
            if (inputCapacidad == null || (inputCapacidad! <= 0)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('La capacidad debe ser mayor a 0')),
              );
              return;
            }

            try {
              final nuevaMesa = Mesa(
                id: '', // ID será generado automáticamente
                nombre: inputMesaName?.trim().isEmpty ?? true
                    ? 'Mesa sin nombre'
                    : inputMesaName!,
                estado: 'Libre',
                capacidad: inputCapacidad ?? 0, // Provide a default value
                tipo: inputTipo ?? 'Principal',
              );
              await _mesaService.agregarMesa(nuevaMesa);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mesa agregada exitosamente')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al agregar la mesa: $e')),
              );
            }
          }
        },
      ),
    );
  }
}
