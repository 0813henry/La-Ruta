import 'package:flutter/material.dart';
import 'package:restaurante_app/routes/app_routes.dart';
import '../../../core/widgets/modules/mesa_card.dart';
import '../../../core/services/mesa_service.dart';
import '../../../core/model/mesa_model.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';

class MesaGrid extends StatelessWidget {
  final MesaService _mesaService = MesaService();
  final Function(Mesa) onMesaTap;
  final bool isWideScreen;

  MesaGrid({required this.onMesaTap, required this.isWideScreen, Key? key})
      : super(key: key);

  Future<void> _cambiarEstadoMesa(BuildContext context, Mesa mesa) async {
    if (mesa.id.isEmpty) {
      debugPrint('Error: El ID de la mesa está vacío en _cambiarEstadoMesa.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: El ID de la mesa no puede estar vacío.')),
      );
      return;
    }

    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Cambiar estado de la mesa'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Libre'),
              child: Text('Libre'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Reservada'),
              child: Text('Reservada'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Ocupada'),
              child: Text('Ocupada'),
            ),
          ],
        );
      },
    );

    if (nuevoEstado != null) {
      try {
        await _mesaService.actualizarEstado(mesa.id, nuevoEstado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Estado de la mesa ${mesa.nombre} actualizado a $nuevoEstado')),
        );
      } catch (e) {
        debugPrint('Error al actualizar el estado de la mesa: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el estado: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Mesa>>(
      stream: _mesaService.obtenerMesas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final mesas = snapshot.data ?? [];
        if (mesas.isEmpty) {
          return Center(child: Text('No hay mesas disponibles.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWideScreen ? 4 : 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1,
          ),
          itemCount: mesas.length,
          itemBuilder: (context, index) {
            final mesa = mesas[index];
            return MesaCard(
              numero: index + 1,
              estado: mesa.estado,
              tipo: mesa.tipo,
              nombre: mesa.nombre,
              onTap: () {
                if (mesa.id.isEmpty) {
                  debugPrint(
                      'Error: El ID de la mesa está vacío al intentar navegar.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Error: El ID de la mesa no puede estar vacío.')),
                  );
                  return;
                }

                Navigator.pushNamed(
                  context,
                  AppRoutes.mesaDetail,
                  arguments: {
                    'mesaId': mesa.id,
                    'nombre': mesa.nombre,
                    'cliente': 'Cliente Desconocido', // Placeholder
                    'numero': index + 1, // Pasar el número de la mesa
                  },
                );
              },
              onLongPress: () => _cambiarEstadoMesa(context, mesa),
            );
          },
        );
      },
    );
  }
}
