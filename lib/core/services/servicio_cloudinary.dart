import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';

class CloudinaryService {
  static const String cloudName = "dlcz1eapw";
  static const String apiKey = "261584556886857";
  static const String apiSecret = "mHCrnBuOvp0BtcewOzRw5OXFsPs";
  static const String folderName =
      "restaurante_app"; // Add your folder name here

  Future<String?> uploadImage(dynamic imageFile) async {
    if (kIsWeb) {
      return await _uploadImageWeb(imageFile);
    } else if (imageFile is File) {
      return await _uploadImageMobile(imageFile);
    } else if (imageFile is XFile) {
      return await _uploadImageMobile(File(imageFile.path));
    } else {
      throw UnsupportedError('Unsupported platform or file type');
    }
  }

  Future<String?> _uploadImageMobile(File imageFile) async {
    final url =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final mimeType =
        lookupMimeType(imageFile.path); // Detect MIME type dynamically
    final request = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = "restaurante_app"
      ..fields["folder"] = folderName // Specify the folder
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType:
            MediaType.parse(mimeType ?? 'image/jpeg'), // Use detected MIME type
      ));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData)["secure_url"];
    } else {
      final errorData = await response.stream.bytesToString();
      throw Exception(
          'Failed to upload image: ${response.statusCode}, $errorData');
    }
  }

  Future<String?> _uploadImageWeb(dynamic imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putData(await imageFile.readAsBytes());
      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
