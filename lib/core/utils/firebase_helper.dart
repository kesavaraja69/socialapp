import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageHelper {
  /// Upload a single video or single file (generic)
  static Future<String> uploadSingleFile(File file, String folderPath) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}";
    final ref = FirebaseStorage.instance.ref().child('$folderPath/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Upload multiple images
  static Future<List<String>> uploadMultipleImages(
    List<File> files,
    String userId,
  ) async {
    List<String> urls = [];
    try {
      for (File file in files) {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        final ref = FirebaseStorage.instance.ref().child(
          'posts/$userId/images/$fileName',
        );
        await ref.putFile(file);
        String imageUrl = await ref.getDownloadURL();
        urls.add(imageUrl);
      }
      return urls;
    } catch (e) {
      debugPrint("image upload failed : $e");
      return [];
    }
  }
}
