// import 'package:flutter/material.dart';
// import 'package:restaurante_app/core/model/pedido_model.dart';
// import 'package:restaurante_app/core/services/servicio_firebase.dart';
// import 'package:restaurante_app/core/services/pedido_service.dart';
// import 'package:restaurante_app/core/model/producto_model.dart';
// import 'package:restaurante_app/core/services/producto_service.dart';
// import '../../widgets/mesero_dashboard/menu_lateral_mesero.dart';
// import '../../widgets/carrito_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../widgets/categoria_selector.dart'; // Importamos el widget CategoriaSelector

// class NuevoPedidoScreen extends StatefulWidget {
//   final String mesaId;
//   final String nombre;
//   final OrderModel? pedido; // <-- Nuevo parámetro opcional

//   const NuevoPedidoScreen({
//     required this.mesaId,
//     required this.nombre,
//     this.pedido, // <-- Nuevo
//     super.key,
//   });

//   @override
//   _NuevoPedidoScreenState createState() => _NuevoPedidoScreenState();
// }

// class _NuevoPedidoScreenState extends State<NuevoPedidoScreen> {
//   final List<OrderItem> _cart = [];
//   bool _isLoading = true;
//   String? _selectedCategory;

//   // Para edición
//   String? _cliente;
//   String? _tipo;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.pedido != null) {
//       // Si es edición, carga los datos del pedido
//       _cart.clear();
//       _cart.addAll(List<OrderItem>.from(widget.pedido!.items));
//       _cliente = widget.pedido!.cliente;
//       _tipo = widget.pedido!.tipo;
//       _isLoading = false;
//     } else {
//       _cargarCarrito();
//     }
//   }

//   Future<void> _cargarCarrito() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('carritos')
//           .doc(widget.mesaId)
//           .get();

//       if (snapshot.exists) {
//         final data = snapshot.data();
//         final items = (data?['items'] as List<dynamic>?)
//             ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
//             .where(
//                 (item) => item.idProducto.isNotEmpty) // Solo productos válidos
//             .toList();

//         if (items != null) {
//           setState(() {
//             _cart.clear();
//             _cart.addAll(items);
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error al cargar el carrito: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _guardarCarrito() async {
//     try {
//       final data = {
//         'mesaId': widget.mesaId,
//         'items': _cart.map((item) => item.toMap()).toList(),
//       };

//       await FirebaseFirestore.instance
//           .collection('carritos')
//           .doc(widget.mesaId)
//           .set(data);
//     } catch (e) {
//       debugPrint('Error al guardar el carrito: $e');
//     }
//   }

//   void _addToCart(Product product, int quantity, String comment) {
//     setState(() {
//       final existingItem = _cart.firstWhere(
//         (item) => item.idProducto == product.id,
//         orElse: () => OrderItem(
//             idProducto: product.id,
//             nombre: product.name,
//             cantidad: 0,
//             precio: product.price,
//             descripcion: '',
//             adicionales: const []),
//       );

//       final currentQuantity = existingItem.cantidad;
//       final newQuantity = currentQuantity + quantity;

//       if (newQuantity > product.stock) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'No puedes agregar más de ${product.stock} unidades de ${product.name}.'),
//           ),
//         );
//         return;
//       }

//       if (currentQuantity == 0) {
//         _cart.add(existingItem);
//       }

//       existingItem.cantidad = newQuantity;
//       existingItem.descripcion = comment;
//     });
//     _guardarCarrito();
//     _updateTotal();
//   }

//   void _removeFromCart(OrderItem item) {
//     setState(() {
//       _cart.remove(item);
//     });
//     _guardarCarrito();
//     _updateTotal(); // Update total after removing from cart
//   }

//   void _updateCartItem(OrderItem item, int newQuantity, String newComment) {
//     setState(() {
//       item.cantidad = newQuantity;
//       item.descripcion = newComment;
//     });
//     _guardarCarrito();
//     _updateTotal(); // Update total after updating an item
//   }

//   void _updateTotal() {
//     final total = _cart.fold(0.0, (sum, item) {
//       final adicionalesTotal = item.adicionales.fold(
//         0.0,
//         (sum, adicional) => sum + (adicional['price'] as double),
//       );
//       return sum + (item.precio + adicionalesTotal) * item.cantidad;
//     });
//     setState(() {
//       // Update the total state if needed
//     });
//   }

//   void _showCartDetails(OrderItem item) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setModalState) {
//           final TextEditingController commentController =
//               TextEditingController(text: item.descripcion);
//           final TextEditingController quantityController =
//               TextEditingController(text: item.cantidad.toString());

//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//               left: 16,
//               right: 16,
//               top: 16,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     item.nombre,
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.remove),
//                         onPressed: () {
//                           if (item.cantidad > 1) {
//                             setModalState(() {
//                               item.cantidad -= 1;
//                               quantityController.text =
//                                   item.cantidad.toString();
//                             });
//                           }
//                         },
//                       ),
//                       SizedBox(
//                         width: 50,
//                         child: TextField(
//                           controller: quantityController,
//                           textAlign: TextAlign.center,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.add),
//                         onPressed: () {
//                           if (item.cantidad < item.precio) {
//                             // Validate stock
//                             setModalState(() {
//                               item.cantidad += 1;
//                               quantityController.text =
//                                   item.cantidad.toString();
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                     'No puedes agregar más de ${item.precio} unidades.'),
//                               ),
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: commentController,
//                     decoration: InputDecoration(
//                       labelText: 'Comentario (opcional)',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       final updatedQuantity =
//                           int.tryParse(quantityController.text) ??
//                               item.cantidad;
//                       final updatedComment = commentController.text;

//                       if (updatedQuantity > item.precio) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                                 'No puedes agregar más de ${item.precio} unidades.'),
//                           ),
//                         );
//                         return;
//                       }

//                       setState(() {
//                         _updateCartItem(item, updatedQuantity, updatedComment);
//                       });
//                       Navigator.pop(context);
//                     },
//                     icon: Icon(Icons.update),
//                     label: Text('Actualizar'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       _removeFromCart(item);
//                       Navigator.pop(context);
//                     },
//                     icon: Icon(Icons.delete),
//                     label: Text('Eliminar'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showProductDetails(Product product) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setModalState) {
//           int selectedQuantity = 1;
//           String selectedComment = '';
//           int availableStock = product.stock; // Fetch stock from product
//           final TextEditingController commentController =
//               TextEditingController();

//           return LayoutBuilder(
//             builder: (context, constraints) {
//               final isWideScreen = constraints.maxWidth > 600;

//               return Padding(
//                 padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom,
//                   left: 16,
//                   right: 16,
//                   top: 16,
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         product.name,
//                         style: TextStyle(
//                           fontSize: isWideScreen ? 24 : 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       if (product.imageUrl != null &&
//                           product.imageUrl!.isNotEmpty)
//                         Image.network(
//                           product.imageUrl!,
//                           height: isWideScreen ? 200 : 150,
//                           fit: BoxFit.cover,
//                         ),
//                       SizedBox(height: 8),
//                       Text(
//                         product.descripcion ?? 'Sin descripción disponible.',
//                         style: TextStyle(fontSize: isWideScreen ? 18 : 14),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Precio: \$${product.price.toStringAsFixed(2)}',
//                         style: TextStyle(
//                           fontSize: isWideScreen ? 18 : 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Stock disponible: $availableStock',
//                         style: TextStyle(
//                           fontSize: isWideScreen ? 16 : 14,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.remove),
//                             onPressed: selectedQuantity > 1
//                                 ? () {
//                                     setModalState(() {
//                                       selectedQuantity--;
//                                     });
//                                   }
//                                 : null, // Disable if quantity is 1
//                           ),
//                           SizedBox(
//                             width: 50,
//                             child: Text(
//                               selectedQuantity.toString(),
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.add),
//                             onPressed: selectedQuantity < availableStock
//                                 ? () {
//                                     setModalState(() {
//                                       selectedQuantity++;
//                                     });
//                                   }
//                                 : null, // Disable if quantity exceeds stock
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       TextField(
//                         controller: commentController,
//                         decoration: InputDecoration(
//                           labelText: 'Comentario (opcional)',
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (value) {
//                           selectedComment = value; // Update comment
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: selectedQuantity <= availableStock
//                             ? () {
//                                 _addToCart(
//                                     product, selectedQuantity, selectedComment);
//                                 Navigator.pop(context);
//                               }
//                             : null, // Disable if quantity exceeds stock
//                         child: Text('Agregar al Pedido'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _confirmOrder() async {
//     String cliente = _cliente ?? widget.nombre;
//     String tipo = _tipo ?? 'Local';
//     final TextEditingController clienteController =
//         TextEditingController(text: cliente);
//     String selectedTipo = tipo;
//     final tipos = ['Local', 'Domicilio', 'VIP'];

//     final result = await showDialog<Map<String, String>>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Datos del Cliente'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: clienteController,
//                 decoration: InputDecoration(
//                   labelText: 'Nombre del Cliente',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: selectedTipo,
//                 items: tipos
//                     .map((t) => DropdownMenuItem(
//                           value: t,
//                           child: Text(t),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   if (value != null) selectedTipo = value;
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Tipo de Pedido',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, null),
//               child: Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, {
//                   'cliente': clienteController.text.trim(),
//                   'tipo': selectedTipo,
//                 });
//               },
//               child: Text(widget.pedido != null ? 'Modificar' : 'Confirmar'),
//             ),
//           ],
//         );
//       },
//     );

//     if (result == null || result['cliente']!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Debes ingresar el nombre del cliente y tipo.')),
//       );
//       return;
//     }

//     // --- Validación de stock antes de confirmar/modificar ---
//     final productoService = ProductoService();
//     bool stockOk = true;
//     String? errorMsg;

//     // Si es modificación, calcula diferencias de stock
//     Map<String, int> stockCambios =
//         {}; // idProducto -> cantidad a descontar (+) o devolver (-)
//     Map<String, int> stockActual =
//         {}; // idProducto -> stock actual en base de datos

//     if (widget.pedido != null) {
//       // Mapear cantidades originales
//       final Map<String, int> original = {};
//       for (final item in widget.pedido!.items) {
//         original[item.idProducto] =
//             (original[item.idProducto] ?? 0) + item.cantidad;
//       }
//       // Mapear cantidades nuevas
//       final Map<String, int> nuevo = {};
//       for (final item in _cart) {
//         nuevo[item.idProducto] = (nuevo[item.idProducto] ?? 0) + item.cantidad;
//       }
//       // Calcular cambios
//       final ids = {...original.keys, ...nuevo.keys};
//       for (final id in ids) {
//         final cantOriginal = original[id] ?? 0;
//         final cantNueva = nuevo[id] ?? 0;
//         stockCambios[id] = cantNueva - cantOriginal;
//       }
//     } else {
//       // Nuevo pedido: solo descontar lo nuevo
//       for (final item in _cart) {
//         stockCambios[item.idProducto] =
//             (stockCambios[item.idProducto] ?? 0) + item.cantidad;
//       }
//     }

//     // Validar stock y preparar cambios
//     for (final entry in stockCambios.entries) {
//       final idProducto = entry.key;
//       final cambio = entry.value;
//       final producto = await productoService.obtenerProductoPorId(idProducto);
//       if (producto == null) {
//         stockOk = false;
//         errorMsg =
//             'El producto con ID "$idProducto" no está disponible actualmente.';
//         break;
//       }
//       stockActual[idProducto] = producto.stock;
//       if (cambio > 0 && cambio > producto.stock) {
//         stockOk = false;
//         errorMsg =
//             'No hay suficiente stock para "${producto.name}". Disponible: ${producto.stock}, solicitado extra: $cambio.';
//         break;
//       }
//     }

//     if (!stockOk) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(errorMsg ?? 'Stock insuficiente')),
//       );
//       return;
//     }

//     // Aplicar cambios de stock
//     for (final entry in stockCambios.entries) {
//       final idProducto = entry.key;
//       final cambio = entry.value;
//       final stock = stockActual[idProducto]!;
//       final nuevoStock = stock - cambio;
//       await productoService.actualizarProductoStock(idProducto, nuevoStock);
//     }

//     final total = _cart.fold(0.0, (sum, item) {
//       final adicionalesTotal = item.adicionales.fold(
//         0.0,
//         (sum, adicional) => sum + (adicional['price'] as double),
//       );
//       return sum + (item.precio + adicionalesTotal) * item.cantidad;
//     });

//     if (widget.pedido != null) {
//       // Modificar pedido existente
//       final pedidoModificado = widget.pedido!.copyWith(
//         cliente: result['cliente']!,
//         tipo: result['tipo']!,
//         items: List<OrderItem>.from(_cart),
//         total: total,
//       );
//       try {
//         await PedidoService().actualizarPedido(pedidoModificado);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Pedido modificado exitosamente')),
//         );
//         setState(() {
//           _cart.clear();
//         });
//         await _guardarCarrito();

//         Navigator.of(context, rootNavigator: true)
//             .popUntil((route) => route.isFirst);

//         Navigator.pushReplacementNamed(context, '/pedidos');
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error al modificar el pedido: $e')),
//         );
//       }
//     } else {
//       // Crear nuevo pedido
//       final order = OrderModel(
//         cliente: result['cliente']!,
//         items: List<OrderItem>.from(_cart),
//         total: total,
//         estado: 'Pendiente',
//         tipo: result['tipo']!,
//         startTime: DateTime.now(),
//       );
//       try {
//         await PedidoService().crearPedido(order);

//         // Send SMS notification
//         await PedidoService().enviarSMS('Pedido enviado exitosamente.');

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Pedido enviado exitosamente')),
//         );
//         setState(() {
//           _cart.clear();
//         });
//         await _guardarCarrito();

//         Navigator.of(context, rootNavigator: true)
//             .popUntil((route) => route.isFirst);

//         Navigator.pushReplacementNamed(context, '/pedidos');
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error al enviar el pedido: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _closeMesa() async {
//     try {
//       await PedidoService().cerrarMesa(widget.mesaId, 'cajeroId_placeholder');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Mesa cerrada exitosamente')),
//       );
//       setState(() {
//         _cart.clear(); // Vaciar el carrito al cerrar la mesa
//       });
//       Navigator.pop(context); // Regresar a la pantalla anterior
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error al cerrar la mesa: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Nuevo Pedido - Mesa ${widget.nombre}'),
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.pedido != null
//             ? 'Modificar Pedido - Mesa ${widget.nombre}'
//             : 'Nuevo Pedido - Mesa ${widget.nombre}'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.shopping_cart),
//             onPressed: () {
//               final total = _cart.fold(
//                   0.0, (sum, item) => sum + item.precio * item.cantidad);
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 builder: (context) => FractionallySizedBox(
//                   heightFactor: 0.9,
//                   child: Column(
//                     children: [
//                       CarritoWidget(
//                         cartItems: _cart,
//                         onEditItem: (item) => _showCartDetails(item),
//                         onRemoveItem: _removeFromCart,
//                         total: total,
//                         onConfirmOrder: _confirmOrder,
//                         confirmButtonText: widget.pedido != null
//                             ? 'Modificar Pedido'
//                             : 'Confirmar Pedido',
//                         divisiones:
//                             widget.pedido?.divisiones, // <-- Añadir aquí
//                       ),
//                       // Mostrar divisiones si existen y es edición
//                       if (widget.pedido != null &&
//                           widget.pedido!.divisiones != null &&
//                           widget.pedido!.divisiones!.isNotEmpty)
//                         Expanded(
//                           child: Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: ListView(
//                               children: widget.pedido!.divisiones!.entries
//                                   .map((entry) {
//                                 final division = entry.key;
//                                 final productos = entry.value;
//                                 return Card(
//                                   margin:
//                                       const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: ExpansionTile(
//                                     title: Text(
//                                       'División: $division',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16),
//                                     ),
//                                     children: productos.map((producto) {
//                                       final adicionalesTotal =
//                                           producto.adicionales.fold(
//                                         0.0,
//                                         (sum, adicional) =>
//                                             sum +
//                                             (adicional['price'] as double),
//                                       );
//                                       final itemTotal =
//                                           (producto.precio + adicionalesTotal) *
//                                               producto.cantidad;
//                                       return ListTile(
//                                         title: Text(
//                                             '${producto.nombre} x${producto.cantidad}'),
//                                         subtitle: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             if (producto.descripcion.isNotEmpty)
//                                               Text(
//                                                 'Comentario: ${producto.descripcion}',
//                                                 style: TextStyle(
//                                                     color: Colors.grey[700]),
//                                               ),
//                                             Text(
//                                               'Precio base: \$${producto.precio.toStringAsFixed(2)}',
//                                               style: TextStyle(
//                                                   color: Colors.grey[700]),
//                                             ),
//                                             if (producto.adicionales.isNotEmpty)
//                                               Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     'Adicionales:',
//                                                     style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color:
//                                                             Colors.grey[800]),
//                                                   ),
//                                                   ...producto.adicionales
//                                                       .map((ad) => Text(
//                                                             '${ad['name']} - \$${(ad['price'] as double).toStringAsFixed(2)}',
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .grey[600]),
//                                                           )),
//                                                 ],
//                                               ),
//                                             SizedBox(height: 4),
//                                             Text(
//                                               'Subtotal: \$${itemTotal.toStringAsFixed(2)}',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.green,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }).toList(),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: MenuLateralMesero(),
//       body: OrientationBuilder(
//         builder: (context, orientation) {
//           final isPortrait = orientation == Orientation.portrait;

//           return Column(
//             children: [
//               CategoriaSelector(
//                 onCategorySelected: (selectedCategory) {
//                   setState(() {
//                     _selectedCategory = selectedCategory;
//                   });
//                 },
//               ),
//               Expanded(
//                 child: StreamBuilder<List<Product>>(
//                   stream: FirebaseService()
//                       .getFilteredProductsStream(_selectedCategory),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     }
//                     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return Center(
//                           child: Text('No hay productos disponibles.'));
//                     }
//                     final crossAxisCount = isPortrait ? 2 : 3;

//                     return GridView.builder(
//                       padding: const EdgeInsets.all(8.0),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: crossAxisCount,
//                         crossAxisSpacing: 8.0,
//                         mainAxisSpacing: 8.0,
//                         childAspectRatio: isPortrait ? 3 / 4 : 3 / 2,
//                       ),
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         final product = snapshot.data![index];
//                         return GestureDetector(
//                           onTap: () => _addToCart(
//                               product, 1, ''), // Add directly to cart
//                           child: Card(
//                             elevation: 6,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.vertical(
//                                       top: Radius.circular(12)),
//                                   child: Image.network(
//                                     product.imageUrl ?? '',
//                                     height: isPortrait ? 120 : 100,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     children: [
//                                       Text(
//                                         product.name,
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         '\$${product.price.toStringAsFixed(2)}',
//                                         style: TextStyle(
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 14,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         'Stock: ${product.stock}',
//                                         style: TextStyle(
//                                           color: Colors.grey[600],
//                                           fontSize: 12,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
