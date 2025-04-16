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
          Mesa(id: 'P$i', estado: 'Libre', capacidad: 4, tipo: 'Principal'),
        for (int i = 1; i <= 4; i++)
          Mesa(id: 'V$i', estado: 'Libre', capacidad: 6, tipo: 'VIP'),
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
        backgroundColor: AppColors.primary,
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
                    Navigator.pushNamed(
                      context,
                      AppRoutes.mesaDetail,
                      arguments: {'mesaId': mesa.id, 'estado': mesa.estado},
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
          String? inputMesaId;
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
                      decoration: InputDecoration(labelText: 'ID de la Mesa'),
                      onChanged: (value) => inputMesaId = value,
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
                      items: ['Principal', 'VIP']
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
            inputMesaId = inputMesaId?.trim(); // Remove leading/trailing spaces

            if (inputMesaId?.isEmpty ?? true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('El ID de la mesa no puede estar vacío')),
              );
              return;
            }

            if (inputCapacidad == null || inputCapacidad! <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('La capacidad debe ser mayor a 0')),
              );
              return;
            }

            if (inputTipo == null || (inputTipo?.isEmpty ?? true)) {
              inputTipo = 'Principal'; // Default value
            }

            try {
              await _mesaService.agregarMesa(
                Mesa(
                  id: inputMesaId ?? '',
                  estado: 'Libre',
                  capacidad: inputCapacidad ?? 0,
                  tipo: inputTipo ?? 'Principal',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Mesa $inputMesaId agregada exitosamente')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al agregar la mesa: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Todos los campos son obligatorios')),
            );
          }
        },
      ),
    );
  }
}
