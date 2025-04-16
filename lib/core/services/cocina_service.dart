import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/pedido_model.dart';

class CocinaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> obtenerPedidosEnCocina() {
    return _firestore
        .collection('pedidos')
        .where('estado', isEqualTo: 'En cocina')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> actualizarEstadoPedido(
      String pedidoId, String nuevoEstado) async {
    await _firestore.collection('pedidos').doc(pedidoId).update({
      'estado': nuevoEstado,
    });
  }
}
