import 'package:flutter/material.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/widgets/modules/categoria_card.dart';
import 'package:restaurante_app/core/services/servicio_firebase.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/core/widgets/categoria_filter_widget.dart';
import '../widgets/pedido_summary.dart';
import '../widgets/menu_lateral_mesero.dart';
import '../widgets/carrito_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/categoria_selector.dart'; // Importamos el widget CategoriaSelector

class NuevoPedidoScreen extends StatefulWidget {
  final String mesaId;
  final String nombre;

  const NuevoPedidoScreen({
    required this.mesaId,
    required this.nombre,
    Key? key,
  }) : super(key: key);

  @override
  _NuevoPedidoScreenState createState() => _NuevoPedidoScreenState();
}

class _NuevoPedidoScreenState extends State<NuevoPedidoScreen> {
  final List<OrderItem> _cart = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  Future<void> _cargarCarrito() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('carritos')
          .doc(widget.mesaId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final items = (data?['items'] as List<dynamic>?)
            ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
            .toList();

        if (items != null) {
          setState(() {
            _cart.clear();
            _cart.addAll(items);
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar el carrito: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarCarrito() async {
    try {
      final data = {
        'mesaId': widget.mesaId,
        'items': _cart.map((item) => item.toMap()).toList(),
      };

      await FirebaseFirestore.instance
          .collection('carritos')
          .doc(widget.mesaId)
          .set(data);
    } catch (e) {
      debugPrint('Error al guardar el carrito: $e');
    }
  }

  void _addToCart(Product product, int quantity, String comment) {
    setState(() {
      final existingItem = _cart.firstWhere(
        (item) => item.nombre == product.name,
        orElse: () => OrderItem(
            nombre: product.name,
            cantidad: 0,
            precio: product.price,
            descripcion: ''),
      );
      if (existingItem.cantidad == 0) {
        _cart.add(existingItem);
      }
      existingItem.cantidad += quantity;
      existingItem.descripcion = comment;
    });
    _guardarCarrito();
  }

  void _removeFromCart(OrderItem item) {
    setState(() {
      _cart.remove(item);
    });
    _guardarCarrito();
  }

  void _updateCartItem(OrderItem item, int newQuantity, String newComment) {
    setState(() {
      item.cantidad = newQuantity;
      item.descripcion = newComment;
    });
    _guardarCarrito(); // Ensure the cart is saved after updating an item
  }

  void _showCartDetails(OrderItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final TextEditingController commentController =
              TextEditingController(text: item.descripcion);
          final TextEditingController quantityController =
              TextEditingController(text: item.cantidad.toString());

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.nombre,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (item.cantidad > 1) {
                            setModalState(() {
                              item.cantidad -= 1;
                              quantityController.text =
                                  item.cantidad.toString();
                            });
                          }
                        },
                      ),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: quantityController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setModalState(() {
                            item.cantidad += 1;
                            quantityController.text = item.cantidad.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'Comentario (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final updatedQuantity =
                          int.tryParse(quantityController.text) ??
                              item.cantidad;
                      final updatedComment = commentController.text;

                      setState(() {
                        _updateCartItem(item, updatedQuantity, updatedComment);
                      });
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.update),
                    label: Text('Actualizar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _removeFromCart(item);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          int selectedQuantity = 1;
          String selectedComment = '';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 600;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: isWideScreen ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (product.imageUrl != null &&
                          product.imageUrl!.isNotEmpty)
                        Image.network(
                          product.imageUrl!,
                          height: isWideScreen ? 200 : 150,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(height: 8),
                      Text(
                        product.descripcion ?? 'Sin descripción disponible.',
                        style: TextStyle(fontSize: isWideScreen ? 18 : 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Precio: \$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isWideScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (selectedQuantity > 1) {
                                setModalState(() {
                                  selectedQuantity--;
                                });
                              }
                            },
                          ),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(
                                  text: selectedQuantity.toString()),
                              onSubmitted: (value) {
                                final quantity = int.tryParse(value) ?? 1;
                                if (quantity > 0) {
                                  setModalState(() {
                                    selectedQuantity = quantity;
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setModalState(() {
                                selectedQuantity++;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Comentario (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            selectedComment = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _addToCart(
                              product, selectedQuantity, selectedComment);
                          Navigator.pop(context);
                        },
                        child: Text('Agregar al Pedido'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmOrder() async {
    final total =
        _cart.fold(0.0, (sum, item) => sum + item.precio * item.cantidad);
    final order = OrderModel(
      cliente: widget.nombre,
      items: _cart,
      total: total,
      estado: 'Pendiente', // Pedido marcado como pendiente
      tipo: 'Local',
      startTime: DateTime.now(),
    );

    try {
      await PedidoService().crearPedido(order);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido enviado exitosamente')),
      );
      // No vaciamos el carrito aquí
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el pedido: $e')),
      );
    }
  }

  Future<void> _closeMesa() async {
    try {
      await PedidoService()
          .cerrarMesa(widget.mesaId, 'cajeroId'); // Enviar a caja
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesa cerrada exitosamente')),
      );
      setState(() {
        _cart.clear(); // Vaciar el carrito al cerrar la mesa
      });
      Navigator.pop(context); // Regresar a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar la mesa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Nuevo Pedido - Mesa ${widget.nombre}'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Pedido - Mesa ${widget.nombre}'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              final total = _cart.fold(
                  0.0, (sum, item) => sum + item.precio * item.cantidad);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.9,
                  child: CarritoWidget(
                    cartItems: _cart, // Lista de elementos en el carrito
                    onEditItem: (item) =>
                        _showCartDetails(item), // Editar un ítem
                    onRemoveItem: _removeFromCart, // Eliminar un ítem
                    total: total, // Total del carrito
                    onConfirmOrder: _confirmOrder, // Confirmar pedido
                    onCloseMesa: _closeMesa, // Cerrar mesa
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: MenuLateralMesero(),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;

          return Column(
            children: [
              CategoriaSelector(
                onCategorySelected: (selectedCategory) {
                  setState(() {
                    _selectedCategory = selectedCategory;
                  });
                },
              ),
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: FirebaseService()
                      .getFilteredProductsStream(_selectedCategory),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No hay productos disponibles.'));
                    }

                    final crossAxisCount = isPortrait ? 2 : 3;

                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: isPortrait ? 3 / 4 : 3 / 2,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final product = snapshot.data![index];
                        return GestureDetector(
                          onTap: () => _showProductDetails(product),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  child: Image.network(
                                    product.imageUrl ?? '',
                                    height: isPortrait ? 100 : 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
