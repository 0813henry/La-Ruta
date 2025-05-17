import 'package:flutter/material.dart';
import '../../../../core/model/pedido_model.dart';
import '../../../../core/services/pedido_service.dart';

class DividirCuentaScreen extends StatefulWidget {
  final String mesaId;
  final List<OrderItem> productos;
  final OrderModel pedido; // <-- Agrega este parámetro

  const DividirCuentaScreen({
    required this.mesaId,
    required this.productos,
    required this.pedido, // <-- Requerido
    super.key,
  });

  @override
  _DividirCuentaScreenState createState() => _DividirCuentaScreenState();
}

class _DividirCuentaScreenState extends State<DividirCuentaScreen> {
  final PedidoService _pedidoService = PedidoService();
  final Map<String, List<OrderItem>> _mesasDivididas = {};
  final List<String> _divisiones = [];
  int _divisionCounter = 1;
  final Map<OrderItem, String?> _asignaciones = {};
  String? _idDivisiones;

  @override
  void initState() {
    super.initState();
    // Si ya existen divisiones en el pedido, cargarlas
    if (widget.pedido.divisiones != null &&
        widget.pedido.divisiones!.isNotEmpty) {
      _mesasDivididas.addAll(widget.pedido.divisiones!);
      _divisiones.addAll(widget.pedido.divisiones!.keys);
      // Opcional: setear el contador para evitar nombres repetidos
      _divisionCounter = _divisiones.length + 1;
      // Cargar idDivisiones si existe
      _idDivisiones = widget.pedido.idDivisiones;
    }
  }

  void _crearNuevaDivision() async {
    String? nombreDivision;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Nombre de la división'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Ej: Juan, Familia, etc.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                nombreDivision = controller.text.trim();
                Navigator.pop(context);
              },
              child: Text('Crear'),
            ),
          ],
        );
      },
    );
    setState(() {
      final nuevaDivision =
          (nombreDivision != null && nombreDivision!.isNotEmpty)
              ? nombreDivision!
              : 'División $_divisionCounter';
      _divisiones.add(nuevaDivision);
      _mesasDivididas[nuevaDivision] = [];
      _divisionCounter++;
    });
  }

  void _asignarProducto(String? division, OrderItem producto) {
    setState(() {
      // Quitar de la división anterior si existía
      final anterior = _asignaciones[producto];
      if (anterior != null) {
        _mesasDivididas[anterior]?.remove(producto);
      }
      // Asignar a la nueva división
      if (division != null) {
        _mesasDivididas[division]?.add(producto);
      }
      _asignaciones[producto] = division;
    });
  }

  void _quitarDivision(String division) {
    setState(() {
      // Quitar asignaciones de productos a esta división
      _asignaciones.removeWhere((producto, div) => div == division);
      _divisiones.remove(division);
      _mesasDivididas.remove(division);
    });
  }

  void _moverProductoConCantidad(
      String division, OrderItem producto, int cantidad) {
    setState(() {
      // Si la cantidad a mover es igual a la cantidad del producto, mover todo el producto
      if (cantidad >= producto.cantidad) {
        _mesasDivididas[division]?.add(producto);
        widget.productos.remove(producto);
        _asignaciones.remove(producto);
      } else if (cantidad > 0 && cantidad < producto.cantidad) {
        // Si es menor, dividir el producto
        final productoDividido = OrderItem(
          idProducto: producto.idProducto,
          nombre: producto.nombre,
          cantidad: cantidad,
          precio: producto.precio,
          descripcion: producto.descripcion,
          adicionales: List<Map<String, dynamic>>.from(producto.adicionales),
        );
        _mesasDivididas[division]?.add(productoDividido);
        producto.cantidad -= cantidad;
      }
    });
  }

  void _moverProductoEntreDivisiones({
    required String divisionOrigen,
    required OrderItem producto,
  }) async {
    String? divisionDestino;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mover producto'),
          content: DropdownButtonFormField<String>(
            value: null,
            hint: Text('Selecciona destino'),
            items: [
              DropdownMenuItem(
                value: 'principal',
                child: Text('Lista principal'),
              ),
              ..._divisiones
                  .where((d) => d != divisionOrigen)
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d),
                      ))
                  .toList(),
            ],
            onChanged: (value) {
              divisionDestino = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (divisionDestino != null) {
                  Navigator.pop(context, divisionDestino);
                }
              },
              child: Text('Mover'),
            ),
          ],
        );
      },
    ).then((destino) {
      if (destino == null) return;
      setState(() {
        _mesasDivididas[divisionOrigen]?.remove(producto);
        if (destino == 'principal') {
          // Si ya existe el producto en la lista principal, suma la cantidad
          final existente = widget.productos.firstWhere(
              (p) =>
                  p.nombre == producto.nombre &&
                  p.precio == producto.precio &&
                  p.descripcion == producto.descripcion,
              orElse: () => OrderItem(
                  idProducto: producto.idProducto,
                  nombre: producto.nombre,
                  cantidad: 0,
                  precio: producto.precio,
                  descripcion: producto.descripcion,
                  adicionales: producto.adicionales));
          if (widget.productos.contains(existente)) {
            existente.cantidad += producto.cantidad;
          } else {
            widget.productos.add(producto);
          }
        } else {
          _mesasDivididas[destino]?.add(producto);
        }
      });
    });
  }

  Future<void> _guardarDivision() async {
    try {
      // Construir el mapa de divisiones para guardar
      final divisionesMap = <String, List<Map<String, dynamic>>>{};
      for (var entry in _mesasDivididas.entries) {
        divisionesMap[entry.key] =
            entry.value.map((item) => item.toMap()).toList();
      }

      // Generar un id único para las divisiones si no existe
      _idDivisiones ??= DateTime.now().millisecondsSinceEpoch.toString();

      final pedidoId = widget.pedido.id;
      if (pedidoId == null || pedidoId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró el ID del pedido original.')),
        );
        return;
      }

      final pedidoActualizado = OrderModel(
        id: pedidoId,
        cliente: widget.pedido.cliente, // No cambiar el cliente
        items: widget.productos,
        total: widget.productos.fold(0.0, (sum, item) {
          final adicionalesTotal = item.adicionales.fold(
            0.0,
            (sum, adicional) => sum + (adicional['price'] as double),
          );
          return sum + (item.precio + adicionalesTotal) * item.cantidad;
        }),
        estado: widget.pedido.estado,
        tipo: widget.pedido.tipo,
        startTime: widget.pedido.startTime,
        divisiones:
            _mesasDivididas.map((k, v) => MapEntry(k, List<OrderItem>.from(v))),
        idDivisiones: _idDivisiones, // Guardar el identificador de divisiones
      );

      await PedidoService().actualizarPedido(pedidoActualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('División guardada exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la división: $e')),
      );
      print(e);
    }
  }

  double _divisionSubtotal(List<OrderItem> items) {
    double subtotal = 0.0;
    for (var item in items) {
      final adicionalesTotal = item.adicionales.fold(
        0.0,
        (sum, adicional) => sum + (adicional['price'] as double),
      );
      subtotal += (item.precio + adicionalesTotal) * item.cantidad;
    }
    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Dividir Cuenta')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _crearNuevaDivision,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Agregar División'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (_idDivisiones != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                'ID Divisiones: $_idDivisiones',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Productos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.productos.length,
                      itemBuilder: (context, index) {
                        final producto = widget.productos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading:
                                Icon(Icons.fastfood, color: theme.primaryColor),
                            title: Text(
                                '${producto.nombre} x${producto.cantidad}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '\$${(producto.precio * producto.cantidad).toStringAsFixed(2)}'),
                            trailing: _divisiones.isEmpty
                                ? null
                                : ElevatedButton(
                                    child: Text('Dividir'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      String? divisionSeleccionada;
                                      int cantidadAMover = 1;
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Dividir producto'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                DropdownButtonFormField<String>(
                                                  value: divisionSeleccionada,
                                                  hint: Text(
                                                      'Selecciona división'),
                                                  items: _divisiones
                                                      .map((division) =>
                                                          DropdownMenuItem(
                                                            value: division,
                                                            child:
                                                                Text(division),
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    divisionSeleccionada =
                                                        value;
                                                  },
                                                ),
                                                if (producto.cantidad > 1)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16.0),
                                                    child: Row(
                                                      children: [
                                                        Text('Cantidad:'),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          child:
                                                              StatefulBuilder(
                                                            builder: (context,
                                                                setStateDialog) {
                                                              return Slider(
                                                                value: cantidadAMover
                                                                    .toDouble(),
                                                                min: 1,
                                                                max: producto
                                                                    .cantidad
                                                                    .toDouble(),
                                                                divisions: producto
                                                                        .cantidad -
                                                                    1,
                                                                label: cantidadAMover
                                                                    .toString(),
                                                                onChanged:
                                                                    (value) {
                                                                  setStateDialog(
                                                                      () {
                                                                    cantidadAMover =
                                                                        value
                                                                            .toInt();
                                                                  });
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        Text('$cantidadAMover'),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('Cancelar'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (divisionSeleccionada !=
                                                          null &&
                                                      cantidadAMover > 0 &&
                                                      cantidadAMover <=
                                                          producto.cantidad) {
                                                    Navigator.pop(context, {
                                                      'division':
                                                          divisionSeleccionada,
                                                      'cantidad':
                                                          cantidadAMover,
                                                    });
                                                  }
                                                },
                                                child: Text('Mover'),
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((result) {
                                        if (result != null &&
                                            result['division'] != null &&
                                            result['cantidad'] != null) {
                                          _moverProductoConCantidad(
                                              result['division'],
                                              producto,
                                              result['cantidad']);
                                        }
                                      });
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          if (_divisiones.isNotEmpty)
            Container(
              height: 260,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _divisiones.map((division) {
                    final productosDivision = _mesasDivididas[division] ?? [];
                    final subtotal = _divisionSubtotal(productosDivision);
                    return Card(
                      elevation: 4,
                      color: Colors.blueGrey[50],
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: 270,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.group, color: Colors.blueGrey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    division,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  tooltip: 'Quitar división',
                                  onPressed: productosDivision.isEmpty
                                      ? () => _quitarDivision(division)
                                      : null,
                                ),
                              ],
                            ),
                            Divider(height: 1),
                            Expanded(
                              child: productosDivision.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Sin productos',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: productosDivision.length,
                                      itemBuilder: (context, idx) {
                                        final producto = productosDivision[idx];
                                        return ListTile(
                                          dense: true,
                                          leading: Icon(Icons.fastfood,
                                              color: Colors.blueGrey),
                                          title: Text(
                                              '${producto.nombre} x${producto.cantidad}'),
                                          subtitle: Text(
                                              '\$${(producto.precio * producto.cantidad).toStringAsFixed(2)}'),
                                          trailing: IconButton(
                                            icon: Icon(Icons.swap_horiz,
                                                color: Colors.blue),
                                            tooltip: 'Mover producto',
                                            onPressed: () {
                                              _moverProductoEntreDivisiones(
                                                divisionOrigen: division,
                                                producto: producto,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _guardarDivision,
            icon: Icon(Icons.save),
            label: Text('Guardar División'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
