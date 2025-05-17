import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/producto_model.dart';

class ProductoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearProducto(Product producto) async {
    await _firestore.collection('products').add(producto.toMap());
  }

  Future<void> actualizarProducto(Product producto) async {
    await _firestore
        .collection('products')
        .doc(producto.id)
        .update(producto.toMap());
  }

  Future<void> actualizarProductoStock(String productId, int newStock) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'stock': newStock});
    } catch (e) {
      throw Exception('Error al actualizar el stock del producto: $e');
    }
  }

  Stream<List<Product>> obtenerProductos() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Product>> obtenerProductosPorCategoria(String categoria) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: categoria)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<int> obtenerStockProducto(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return doc.data()?['stock'] ?? 0;
    }
    return 0;
  }

  Future<Product?> obtenerProductoPorNombre(String nombre) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('name', isEqualTo: nombre)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Product.fromMap(doc.data(), doc.id);
      }
      return null; // Return null if no product is found
    } catch (e) {
      throw Exception('Error al obtener el producto por nombre: $e');
    }
  }

  Future<Product?> obtenerProductoPorId(String idProducto) async {
    try {
      final doc = await _firestore.collection('products').doc(idProducto).get();
      if (doc.exists) {
        return Product.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener el producto por ID: $e');
    }
  }
}
