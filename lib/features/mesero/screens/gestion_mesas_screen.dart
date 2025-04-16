import 'package:flutter/material.dart';
import '../../../core/services/mesa_service.dart';
import '../widgets/mesa_grid.dart';
import '../../../core/model/mesa_model.dart';

class GestionMesasScreen extends StatefulWidget {
  @override
  _GestionMesasScreenState createState() => _GestionMesasScreenState();
}

class _GestionMesasScreenState extends State<GestionMesasScreen> {
  final MesaService _mesaService = MesaService();
  String _filtro = 'Todas';

  void _agregarMesa() async {
    final nuevaMesa = Mesa(
      id: '',
      estado: 'Libre',
      capacidad: 4,
      tipo: 'Principal',
    );
    await _mesaService.agregarMesa(nuevaMesa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Mesas'),
        actions: [
          DropdownButton<String>(
            value: _filtro,
            items: ['Todas', 'Principal', 'VIP']
                .map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _filtro = value!;
              });
            },
          ),
        ],
      ),
      body: MesaGrid(
        isWideScreen: MediaQuery.of(context).size.width > 600,
        onMesaTap: (mesa) {
          if (mesa.estado == 'Libre') {
            _mesaService.reservarMesa(mesa.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mesa ${mesa.id} reservada')),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarMesa,
        child: Icon(Icons.add),
      ),
    );
  }
}
