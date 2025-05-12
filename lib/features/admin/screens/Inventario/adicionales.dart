import 'package:flutter/material.dart';
import 'package:restaurante_app/core/services/adicional_service.dart';
import 'package:restaurante_app/core/model/adicional_model.dart';
import 'package:restaurante_app/features/admin/widgets/admin_scaffold_layout.dart';

class AdicionalesScreen extends StatefulWidget {
  const AdicionalesScreen({super.key});

  @override
  _AdicionalesScreenState createState() => _AdicionalesScreenState();
}

class _AdicionalesScreenState extends State<AdicionalesScreen> {
  final AdicionalService _adicionalService = AdicionalService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _editingAdicionalId;
  bool _isLoading = false;

  Future<void> _addOrUpdateAdicional() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adicional = Adicional(
        id: _editingAdicionalId ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
      );

      if (_editingAdicionalId == null) {
        await _adicionalService.crearAdicional(adicional);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adicional agregado exitosamente')),
        );
      } else {
        await _adicionalService.actualizarAdicional(adicional);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adicional actualizado exitosamente')),
        );
      }

      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el adicional: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    _nameController.clear();
    _priceController.clear();
    setState(() {
      _editingAdicionalId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffoldLayout(
      title: Row(
        children: [
          const Expanded(child: Text('Gestión de Adicionales')),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _clearFields,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del Adicional',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addOrUpdateAdicional,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(_editingAdicionalId == null
                              ? 'Agregar Adicional'
                              : 'Actualizar Adicional'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Adicional>>(
                  stream: _adicionalService.obtenerAdicionales(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error al cargar los adicionales'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No hay adicionales disponibles'));
                    }
                    final adicionales = snapshot.data!;
                    return ListView.builder(
                      itemCount: adicionales.length,
                      itemBuilder: (context, index) {
                        final adicional = adicionales[index];
                        return ListTile(
                          title: Text(adicional.name),
                          subtitle: Text('Precio: \$${adicional.price}'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _nameController.text = adicional.name;
                                _priceController.text =
                                    adicional.price.toString();
                                _editingAdicionalId = adicional.id;
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
