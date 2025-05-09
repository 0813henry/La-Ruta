import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/adicional_model.dart';

class AdicionalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearAdicional(Adicional adicional) async {
    await _firestore.collection('adicionales').add(adicional.toMap());
  }

  Future<void> actualizarAdicional(Adicional adicional) async {
    await _firestore
        .collection('adicionales')
        .doc(adicional.id)
        .update(adicional.toMap());
  }

  Stream<List<Adicional>> obtenerAdicionales() {
    return _firestore.collection('adicionales').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Adicional.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
