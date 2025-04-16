import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/producto_model.dart';

class ProductoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearProducto(Product producto) async {
    await _firestore.collection('productos').add(producto.toMap());
  }

  Future<void> actualizarProducto(Product producto) async {
    await _firestore
        .collection('productos')
        .doc(producto.id)
        .update(producto.toMap());
  }

  Future<void> eliminarProducto(String productoId) async {
    await _firestore.collection('productos').doc(productoId).delete();
  }

  Stream<List<Product>> obtenerProductos() {
    return _firestore.collection('productos').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Product>> obtenerProductosPorCategoria(String categoria) {
    return _firestore
        .collection('productos')
        .where('category', isEqualTo: categoria)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
