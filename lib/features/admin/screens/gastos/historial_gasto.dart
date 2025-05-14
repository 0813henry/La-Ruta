// import 'package:flutter/material.dart';
// import 'package:restaurante_app/core/services/gasto_service.dart';
// import 'package:restaurante_app/core/model/gasto_model.dart';
// import 'package:restaurante_app/features/admin/screens/gastos/agregar_gasto.dart';
// import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';
// import 'widgets/detalle_gasto.dart';

// class HistorialGastoScreen extends StatelessWidget {
//   final GastoService _gastoService = GastoService();

//   HistorialGastoScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AdminScaffoldLayout(
//       title: Row(
//         children: [
//           const Expanded(child: Text('Historial de Gastos')),
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return Dialog(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: AgregarGastoWidget(
//                         onAgregar: (imagen, descripcion, valor) {
//                           Navigator.pop(
//                               context); // Cierra el diálogo después de guardar
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                                 content: Text('Gasto agregado exitosamente')),
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<Gasto>>(
//         stream: _gastoService.obtenerGastos(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error al cargar los gastos.'));
//           }
//           final gastos = snapshot.data ?? [];
//           if (gastos.isEmpty) {
//             return Center(child: Text('No hay gastos registrados.'));
//           }
//           return ListView.builder(
//             itemCount: gastos.length,
//             itemBuilder: (context, index) {
//               final gasto = gastos[index];
//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: ListTile(
//                   leading: gasto.imagenUrl != null
//                       ? Image.network(
//                           gasto.imagenUrl!,
//                           width: 50,
//                           height: 50,
//                           fit: BoxFit.cover,
//                         )
//                       : Icon(Icons.money_off, size: 50, color: Colors.teal),
//                   title: Text(gasto.descripcion),
//                   subtitle: Text(
//                       'Valor: \$${gasto.valor.toStringAsFixed(2)}\nFecha: ${gasto.fecha.toLocal()}'),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DetalleGastoWidget(gasto: gasto),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:restaurante_app/core/constants/app_colors.dart';
import 'package:restaurante_app/core/model/gasto_model.dart';
import 'package:restaurante_app/core/services/gasto_service.dart';
import 'package:restaurante_app/features/admin/screens/gastos/agregar_gasto.dart';
import 'package:restaurante_app/features/admin/screens/gastos/widgets/detalle_gasto.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';

class HistorialGastoScreen extends StatefulWidget {
  const HistorialGastoScreen({super.key});

  @override
  State<HistorialGastoScreen> createState() => _HistorialGastoScreenState();
}

class _HistorialGastoScreenState extends State<HistorialGastoScreen> {
  final GastoService _gastoService = GastoService();

  void _abrirFormularioAgregarGasto() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AgregarGastoBottomSheet(
        onSuccess: () {
          // Rebuild el widget si es necesario tras agregar
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffoldLayout(
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Historial de Gastos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _abrirFormularioAgregarGasto,
          ),
        ],
      ),
      body: StreamBuilder<List<Gasto>>(
        stream: _gastoService.obtenerGastos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los gastos.'));
          }

          final gastos = snapshot.data ?? [];
          if (gastos.isEmpty) {
            return const Center(child: Text('No hay gastos registrados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: gastos.length,
            itemBuilder: (context, index) {
              final gasto = gastos[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: gasto.imagenUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          gasto.imagenUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.attach_money, color: Colors.white),
                      ),
                title: Text(
                  gasto.descripcion,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _formatFecha(gasto.fecha),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: Text(
                  '- \$${gasto.valor.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => DetalleGastoModal(gasto: gasto),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final now = DateTime.now();
    final difference = now.difference(fecha);
    if (difference.inDays == 0) {
      return 'Hoy, ${_formatHora(fecha)}';
    } else if (difference.inDays == 1) {
      return 'Ayer, ${_formatHora(fecha)}';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  String _formatHora(DateTime fecha) {
    final hour = fecha.hour.toString().padLeft(2, '0');
    final minute = fecha.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
