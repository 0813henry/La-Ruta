import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../model/gasto_model.dart';
import 'servicio_cloudinary.dart';

class GastoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> agregarGasto(Gasto gasto, File? imagen) async {
    try {
      if (gasto.descripcion.isEmpty || gasto.valor <= 0) {
        throw Exception(
            'El gasto debe tener una descripción válida y un valor mayor a 0.');
      }

      String? imagenUrl;

      // Subir imagen a Cloudinary si existe
      if (imagen != null) {
        imagenUrl = await _cloudinaryService.uploadImage(imagen);
      }

      // Crear una copia del gasto con la URL de la imagen
      final gastoConImagen = gasto.copyWith(imagenUrl: imagenUrl);

      // Guardar gasto en Firestore
      await _firestore
          .collection('gastos')
          .doc(gastoConImagen.id)
          .set(gastoConImagen.toMap());
    } catch (e) {
      print('Error al agregar gasto: $e');
      rethrow;
    }
  }

  Stream<List<Gasto>> obtenerGastos() {
    return _firestore.collection('gastos').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Gasto.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<Gasto>> obtenerGastosPorRango(
      DateTime inicio, DateTime fin) async {
    try {
      final snapshot = await _firestore
          .collection('gastos')
          .where('fecha', isGreaterThanOrEqualTo: inicio)
          .where('fecha', isLessThanOrEqualTo: fin)
          .get();

      return snapshot.docs
          .map((doc) => Gasto.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error al obtener gastos por rango: $e');
      rethrow;
    }
  }
}
