import 'package:cloud_firestore/cloud_firestore.dart';

// Este archivo contiene el servicio para escuchar notificaciones de cambios en los pedidos.

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void escucharNotificacionesCocina(Function(String pedidoId) onPedidoListo) {
    _firestore.collection('pedidos').snapshots().listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.modified &&
            doc.doc['estado'] == 'Listo') {
          onPedidoListo(doc.doc.id);
        }
      }
    });
  }

  void notificarMesero(String meseroId, String mensaje) {
    _firestore.collection('notificaciones').add({
      'meseroId': meseroId,
      'mensaje': mensaje,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
