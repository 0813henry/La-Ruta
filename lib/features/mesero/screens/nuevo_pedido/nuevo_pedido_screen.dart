import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/core/services/pedido_service.dart';
import 'package:restaurante_app/core/services/producto_service.dart';
import 'package:restaurante_app/features/mesero/screens/nuevo_pedido/widgets/modal_detalle_carrito_sheet.dart';
import 'package:restaurante_app/features/mesero/widgets/categoria_selector.dart';
import 'package:restaurante_app/features/mesero/widgets/mesero_dashboard/menu_lateral_mesero.dart';

import 'widgets/producto_grid.dart';
import 'widgets/modal_detalle_producto.dart';
import 'widgets/modal_detalle_carrito.dart';
import 'widgets/dialog_confirmar_pedido.dart';

class NuevoPedidoScreen extends StatefulWidget {
  final String mesaId;
  final String nombre;
  final OrderModel? pedido;

  const NuevoPedidoScreen({
    required this.mesaId,
    required this.nombre,
    this.pedido,
    super.key,
  });

  @override
  State<NuevoPedidoScreen> createState() => _NuevoPedidoScreenState();
}

class _NuevoPedidoScreenState extends State<NuevoPedidoScreen> {
  final List<OrderItem> _cart = [];
  bool _isLoading = true;
  String? _selectedCategory;
  String? _cliente;
  String? _tipo;

  @override
  void initState() {
    super.initState();
    if (widget.pedido != null) {
      _cart.clear();
      _cart.addAll(List<OrderItem>.from(widget.pedido!.items));
      _cliente = widget.pedido!.cliente;
      _tipo = widget.pedido!.tipo;
      _isLoading = false;
    } else {
      _cargarCarrito();
    }
  }

  Future<void> _cargarCarrito() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('carritos')
          .doc(widget.mesaId)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        final items = (data?['items'] as List<dynamic>?)
            ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
            .where((item) => item.idProducto.isNotEmpty)
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
      setState(() => _isLoading = false);
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
        (item) => item.idProducto == product.id,
        orElse: () => OrderItem(
          idProducto: product.id,
          nombre: product.name,
          cantidad: 0,
          precio: product.price,
          descripcion: '',
          adicionales: const [],
        ),
      );

      final newQuantity = existingItem.cantidad + quantity;

      if (newQuantity > product.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No puedes agregar más de ${product.stock} unidades de ${product.name}.')),
        );
        return;
      }

      if (existingItem.cantidad == 0) {
        _cart.add(existingItem);
      }

      existingItem.cantidad = newQuantity;
      existingItem.descripcion = comment;
    });
    _guardarCarrito();
  }

  void _updateCartItem(OrderItem item, int newQuantity, String newComment) {
    setState(() {
      item.cantidad = newQuantity;
      item.descripcion = newComment;
    });
    _guardarCarrito();
  }

  void _removeFromCart(OrderItem item) {
    setState(() {
      _cart.remove(item);
    });
    _guardarCarrito();
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ModalDetalleProducto(
        product: product,
        onConfirm: (quantity, comment) =>
            _addToCart(product, quantity, comment),
      ),
    );
  }

  Future<void> _showCartDetails(OrderItem item) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ModalDetalleCarrito(
        item: item,
        onUpdate: _updateCartItem,
        onDelete: _removeFromCart,
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _confirmOrder() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => DialogConfirmarPedido(
        nombre: widget.nombre,
        tipoInicial: _tipo,
        clienteInicial: _cliente,
      ),
    );

    if (result != null) {
      final cliente = result['cliente']!;
      final tipo = result['tipo']!;
      await PedidoService().confirmarPedido(
        context: context,
        pedidoExistente: widget.pedido,
        mesaId: widget.mesaId,
        carrito: _cart,
        cliente: cliente,
        tipo: tipo,
      );
      setState(() => _cart.clear());
      await _guardarCarrito();
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacementNamed(context, '/pedidos');
    }
  }

  Future<void> _abrirCarritoConProductos() async {
    final productosStream = ProductoService().obtenerProductos();
    final productos = await productosStream.first;
    final Map<String, Product> productosMap = {
      for (var p in productos) p.id: p,
    };

    final total =
        _cart.fold(0.0, (sum, item) => sum + item.precio * item.cantidad);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ModalDetalleCarritoSheet(
        cart: _cart,
        total: total,
        onConfirm: _confirmOrder,
        onEditItem: _showCartDetails,
        onRemoveItem: _removeFromCart,
        divisiones: widget.pedido?.divisiones,
        confirmButtonText:
            widget.pedido != null ? 'Modificar Pedido' : 'Confirmar Pedido',
        productosDisponibles: productosMap, // ← nuevo parámetro agregado
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Nuevo Pedido - Mesa ${widget.nombre}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pedido != null
            ? 'Modificar Pedido - Mesa ${widget.nombre}'
            : 'Nuevo Pedido - Mesa ${widget.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _abrirCarritoConProductos,
          ),
        ],
      ),
      drawer: const MenuLateralMesero(),
      body: Column(
        children: [
          CategoriaSelector(
            onCategorySelected: (category) =>
                setState(() => _selectedCategory = category),
          ),
          Expanded(
            child: ProductoGrid(
              selectedCategory: _selectedCategory,
              onProductTap: _showProductDetails,
            ),
          ),
        ],
      ),
    );
  }
}
