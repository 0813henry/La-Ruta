import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'package:restaurante_app/core/model/producto_model.dart';
import 'package:restaurante_app/core/services/servicio_cloudinary.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> saveOrderToFirebase(OrderModel order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
  }

  Stream<List<OrderModel>> getOrdersStream() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<List<OrderModel>> getOrdersByMesaId(String mesaId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('cliente', isEqualTo: 'Mesa $mesaId')
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
  }

  Future<void> saveMesaSales(OrderModel order) async {
    await _firestore.collection('ventas').add(order.toMap());
  }

  Future<void> deleteOrdersByMesaId(String mesaId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('cliente', isEqualTo: 'Mesa $mesaId')
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add({
        'name': product.name,
        'descripcion': product.descripcion,
        'price': product.price,
        'category': product.category,
        'stock': product.stock,
        'imageUrl': product.imageUrl, // Add imageUrl field
      });
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }

  Future<void> addProductWithImage(Product product, dynamic imageFile) async {
    try {
      String? imageUrl;
      if (kIsWeb) {
        imageUrl = await _cloudinaryService.uploadImage(imageFile);
      } else if (imageFile is File) {
        imageUrl = await _cloudinaryService.uploadImage(imageFile);
      } else if (imageFile is XFile) {
        imageUrl = await _cloudinaryService.uploadImage(File(imageFile.path));
      }
      if (imageUrl != null) {
        product.imageUrl = imageUrl;
        await addProduct(product);
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Error adding product with image: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Product>> getFilteredProductsStream(String? category) {
    if (category == null || category == 'Todos') {
      return getProductsStream();
    }
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addCategory(String categoryName) async {
    try {
      await _firestore.collection('categories').add({'name': categoryName});
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  Future<void> addCategoryWithImage(
      {required String name, String? imageUrl}) async {
    try {
      await _firestore.collection('categories').add({
        'name': name,
        'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception('Error al agregar la categoría: $e');
    }
  }

  Future<void> updateCategory(
      {required String id, required String name, String? imageUrl}) async {
    try {
      final data = {'name': name};
      if (imageUrl != null) {
        data['imageUrl'] = imageUrl;
      } else {
        data.remove('imageUrl'); // Eliminar el campo si es nulo
      }
      await _firestore.collection('categories').doc(id).update(data);
    } catch (e) {
      throw Exception('Error al actualizar la categoría: $e');
    }
  }

  Stream<List<String>> getCategoriesStream() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getCategoriesWithDetailsStream() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'imageUrl':
              doc.data().containsKey('imageUrl') ? doc['imageUrl'] : null,
        };
      }).toList();
    });
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      final cloudinaryService = CloudinaryService();
      return await cloudinaryService.uploadImage(imageFile);
    } catch (e) {
      throw Exception('Error al subir la imagen a Cloudinary: $e');
    }
  }

  Future<void> addStock(Product product, int stockToAdd) async {
    try {
      final newStock = product.stock + stockToAdd;
      await _firestore.collection('products').doc(product.id).update({
        'stock': newStock,
      });
    } catch (e) {
      throw Exception('Error al agregar stock: $e');
    }
  }
}
