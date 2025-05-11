import 'package:flutter/material.dart';
import '../../../core/services/mesa_service.dart';
import '../widgets/mesa_grid.dart';
import '../../../core/model/mesa_model.dart';

class GestionMesasScreen extends StatefulWidget {
  const GestionMesasScreen({super.key});

  @override
  _GestionMesasScreenState createState() => _GestionMesasScreenState();
}

class _GestionMesasScreenState extends State<GestionMesasScreen> {
  final MesaService _mesaService = MesaService();
  String _filtroTipo = 'Todas';
  String _filtroEstado = 'Todos';

  void _agregarMesa() async {
    final nuevaMesa = Mesa(
      id: 'Mesa-${DateTime.now().millisecondsSinceEpoch}', // Ensure a unique ID
      nombre: 'Mesa Nueva',
      estado: 'Libre',
      capacidad: 4,
      tipo: 'Principal',
    );

    if (nuevaMesa.id.isEmpty) {
      throw Exception(
          'El ID de la mesa no puede estar vacío.'); // Debugging check
    }

    await _mesaService.agregarMesa(nuevaMesa);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mesa ${nuevaMesa.nombre} agregada exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text('Gestión de Mesas'),
            ),
            DropdownButton<String>(
              value: _filtroTipo,
              dropdownColor: Colors.white,
              style: TextStyle(color: Colors.black),
              items: ['Todas', 'Principal', 'VIP', 'Domicilio']
                  .map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _filtroTipo = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filtroEstado = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Todos', child: Text('Todos')),
              PopupMenuItem(value: 'Libre', child: Text('Libre')),
              PopupMenuItem(value: 'Ocupada', child: Text('Ocupada')),
              PopupMenuItem(value: 'Reservada', child: Text('Reservada')),
            ],
            child: Row(
              children: [
                Icon(Icons.filter_alt),
                SizedBox(width: 4),
                Text('Estado'),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Mesa>>(
        stream: _mesaService.obtenerMesas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final mesas = snapshot.data ?? [];
          final mesasFiltradas = mesas.where((mesa) {
            final tipoCoincide =
                _filtroTipo == 'Todas' || mesa.tipo == _filtroTipo;
            final estadoCoincide =
                _filtroEstado == 'Todos' || mesa.estado == _filtroEstado;
            return tipoCoincide && estadoCoincide;
          }).toList();

          if (mesasFiltradas.isEmpty) {
            return Center(child: Text('No hay mesas disponibles.'));
          }

          return MesaGrid(
            isWideScreen: MediaQuery.of(context).size.width > 600,
            onMesaTap: (mesa) {
              if (mesa.estado == 'Libre') {
                _mesaService.reservarMesa(mesa.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mesa ${mesa.id} reservada')),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarMesa,
        child: Icon(Icons.add),
      ),
    );
  }
}
