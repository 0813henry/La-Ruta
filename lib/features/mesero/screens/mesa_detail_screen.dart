import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/mesa_service.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import '../../../routes/app_routes.dart';

class MesaDetailScreen extends StatefulWidget {
  final String mesaId;
  final String estado;
  final String nombre;

  const MesaDetailScreen({
    required this.mesaId,
    required this.estado,
    required this.nombre,
    Key? key,
  }) : super(key: key);

  @override
  _MesaDetailScreenState createState() => _MesaDetailScreenState();
}

class _MesaDetailScreenState extends State<MesaDetailScreen> {
  final MesaService _mesaService = MesaService();
  String _estadoActual = '';

  @override
  void initState() {
    super.initState();
    if (widget.mesaId.isEmpty) {
      debugPrint('Error: El ID de la mesa está vacío en initState.');
    }
    _estadoActual = widget.estado;
  }

  Future<void> _cambiarEstadoMesa() async {
    if (widget.mesaId.isEmpty) {
      debugPrint(
          'Error: El ID de la mesa está vacío al intentar cambiar el estado.');
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
              onPressed: () => Navigator.pop(context, 'Disponible'),
              child: Text('Disponible'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'En Servicio'),
              child: Text('En Servicio'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Reservada'),
              child: Text('Reservada'),
            ),
          ],
        );
      },
    );

    if (nuevoEstado != null) {
      try {
        await _mesaService.actualizarEstado(widget.mesaId, nuevoEstado);
        setState(() {
          _estadoActual = nuevoEstado;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado a $nuevoEstado')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Mesa ${widget.nombre}'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Estado: $_estadoActual'),
            subtitle: Text('Nombre: ${widget.nombre}'),
            leading: Icon(
              _estadoActual == 'Disponible'
                  ? Icons.check_circle
                  : Icons.warning,
              color: _estadoActual == 'Disponible' ? Colors.green : Colors.red,
            ),
            trailing: ElevatedButton(
              onPressed: _cambiarEstadoMesa,
              child: Text('Cambiar Estado'),
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Tomar Pedido'),
            leading: Icon(Icons.restaurant_menu),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.nuevoPedido,
                arguments: {'mesaId': widget.mesaId, 'nombre': widget.nombre},
              );
            },
          ),
        ],
      ),
    );
  }
}
