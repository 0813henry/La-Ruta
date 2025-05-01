import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurante_app/core/model/gasto_model.dart';
import 'package:restaurante_app/core/services/gasto_service.dart';
import 'package:restaurante_app/core/services/servicio_cloudinary.dart';
import 'package:uuid/uuid.dart';
import 'widgets/menu_lateral_gastos.dart';

class AgregarGastoWidget extends StatefulWidget {
  final Function(String? imagen, String descripcion, double valor) onAgregar;

  const AgregarGastoWidget({required this.onAgregar, Key? key})
      : super(key: key);

  @override
  _AgregarGastoWidgetState createState() => _AgregarGastoWidgetState();
}

class _AgregarGastoWidgetState extends State<AgregarGastoWidget> {
  final _descripcionController = TextEditingController();
  final _valorController = TextEditingController();
  String? _imagenPath;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenPath = pickedFile.path;
      });
    }
  }

  void _agregarGasto() async {
    final descripcion = _descripcionController.text.trim();
    final valor = double.tryParse(_valorController.text.trim()) ?? 0.0;

    if (descripcion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La descripción no puede estar vacía.')),
      );
      return;
    }

    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El valor debe ser mayor a 0.')),
      );
      return;
    }

    final id = Uuid().v4();
    final gasto = Gasto(
      id: id,
      descripcion: descripcion,
      valor: valor,
      fecha: DateTime.now(),
    );

    try {
      final gastoService = GastoService();
      await gastoService.agregarGasto(
          gasto, _imagenPath != null ? File(_imagenPath!) : null);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar gasto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Gasto'),
        backgroundColor: Colors.teal,
      ),
      drawer: SidebarMenuGastos(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Nuevo Gasto',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: _seleccionarImagen,
                    child: Container(
                      height: isSmallScreen ? 200 : 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal, width: 2),
                      ),
                      child: _imagenPath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload,
                                    size: 48, color: Colors.teal),
                                SizedBox(height: 8),
                                Text(
                                  'Subir Imagen',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_imagenPath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.teal[50],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _valorController,
                    decoration: InputDecoration(
                      labelText: 'Valor Total',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.teal[50],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _agregarGasto,
                      child: Text(
                        'Agregar',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
