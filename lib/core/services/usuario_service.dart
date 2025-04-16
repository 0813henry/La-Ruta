import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/usuario_model.dart';

class UsuarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> crearUsuario(UserModel usuario) async {
    await _firestore.collection('users').doc(usuario.uid).set(usuario.toMap());
  }

  Future<void> actualizarUsuario(UserModel usuario) async {
    await _firestore
        .collection('users')
        .doc(usuario.uid)
        .update(usuario.toMap());
  }

  Future<void> eliminarUsuario(String usuarioId) async {
    await _firestore.collection('users').doc(usuarioId).delete();
  }

  Future<void> cambiarEstadoUsuario(String usuarioId, bool isActive) async {
    await _firestore.collection('users').doc(usuarioId).update({
      'isActive': isActive,
    });
  }

  Stream<List<UserModel>> obtenerUsuarios() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Future<UserModel?> obtenerUsuarioPorId(String usuarioId) async {
    final doc = await _firestore.collection('users').doc(usuarioId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}
