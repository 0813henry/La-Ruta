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

class NuevoPedidoScreen extends StatefulWidget {
  final String mesaId;
  final String nombre;

  const NuevoPedidoScreen(
      {required this.mesaId, required this.nombre, Key? key})
      : super(key: key);

  @override
  _NuevoPedidoScreenState createState() => _NuevoPedidoScreenState();
}

class _NuevoPedidoScreenState extends State<NuevoPedidoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final PedidoService _pedidoService = PedidoService();
  final List<OrderItem> _cart = [];
  Product? _selectedProduct;
  int _selectedQuantity = 1;
  String _selectedComment = '';
  String? _selectedCategory;
  bool _isOrderSent = false;

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
  }

  void _removeFromCart(OrderItem item) {
    setState(() {
      _cart.remove(item);
    });
  }

  void _updateCartItem(OrderItem item, int newQuantity, String newComment) {
    setState(() {
      item.cantidad = newQuantity;
      item.descripcion = newComment;
    });
  }

  void _showProductDetails(Product product) {
    setState(() {
      _selectedProduct = product;
      _selectedQuantity = 1;
      _selectedComment = '';
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  Image.network(product.imageUrl!,
                      height: 150, fit: BoxFit.cover),
                SizedBox(height: 8),
                Text(product.descripcion),
                SizedBox(height: 8),
                Text('Precio: \$${product.price.toStringAsFixed(2)}'),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (_selectedQuantity > 1) {
                          setModalState(() {
                            _selectedQuantity--;
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
                            text: _selectedQuantity.toString()),
                        onSubmitted: (value) {
                          final quantity = int.tryParse(value) ?? 1;
                          if (quantity > 0) {
                            setModalState(() {
                              _selectedQuantity = quantity;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setModalState(() {
                          _selectedQuantity++;
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
                      _selectedComment = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _addToCart(product, _selectedQuantity, _selectedComment);
                    Navigator.pop(context);
                  },
                  child: Text('Agregar al Pedido'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  void _showCartModal() {
    final total =
        _cart.fold(0.0, (sum, item) => sum + item.precio * item.cantidad);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CarritoWidget(
        cartItems: _cart,
        onEditItem: _showCartDetails,
        onRemoveItem: _removeFromCart,
        total: total,
        onConfirmOrder: _confirmOrder,
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
      estado: 'Pendiente',
      tipo: 'Local',
      startTime: DateTime.now(),
    );

    try {
      await _pedidoService.crearPedido(order);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido enviado exitosamente')),
      );
      setState(() {
        _isOrderSent = true;
        _cart.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Pedido - Mesa ${widget.nombre}'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: _showCartModal,
          ),
        ],
      ),
      drawer: MenuLateralMesero(),
      body: Column(
        children: [
          CategoriaFilterWidget(
            onFilterSelected: (selectedCategory) {
              setState(() {
                _selectedCategory = selectedCategory;
              });
            },
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: isWideScreen ? 2 : 3,
                  child: StreamBuilder<List<Product>>(
                    stream: _firebaseService
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
                      return GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWideScreen ? 3 : 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 3 / 2,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (product.imageUrl != null &&
                                      product.imageUrl!.isNotEmpty)
                                    Image.network(product.imageUrl!,
                                        height: 80, fit: BoxFit.cover),
                                  SizedBox(height: 8),
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text('\$${product.price.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (isWideScreen)
                  VerticalDivider(width: 1, color: Colors.grey[300]),
                if (isWideScreen && _cart.isNotEmpty)
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.grey[200],
                      child: ListView.builder(
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: ListTile(
                              title: Text('${item.nombre} x${item.cantidad}'),
                              subtitle: Text(
                                '\$${(item.precio * item.cantidad).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showCartDetails(item),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
