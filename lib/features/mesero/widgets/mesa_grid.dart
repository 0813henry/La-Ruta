import 'package:flutter/material.dart';
import '../../../core/widgets/modules/mesa_card.dart';
import '../../../core/services/mesa_service.dart';
import '../../../core/model/mesa_model.dart';

class MesaGrid extends StatelessWidget {
  final MesaService _mesaService = MesaService();
  final Function(Mesa) onMesaTap;
  final bool isWideScreen;

  MesaGrid({required this.onMesaTap, required this.isWideScreen, Key? key})
      : super(key: key);

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
              numero: index + 1, // Pasar el número de la mesa
              estado: mesa.estado,
              tipo: mesa.tipo,
              onTap: () => onMesaTap(mesa),
            );
          },
        );
      },
    );
  }
}
