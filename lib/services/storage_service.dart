import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a product image and return its download URL.
  /// Stores images under `products/{productId}/{timestamp}_{filename}`.
  Future<String> uploadProductImage({
    required File imageFile,
    required String productId,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split(Platform.pathSeparator).last}';
    final ref = _storage.ref().child('products/$productId/$fileName');

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }

  /// Delete an image from Firebase Storage by its download URL.
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // Silently fail if image doesn't exist or URL is invalid
    }
  }

  /// Upload a store profile image and return its download URL.
  Future<String> uploadStoreImage({
    required File imageFile,
    required String sellerId,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split(Platform.pathSeparator).last}';
    final ref = _storage.ref().child('stores/$sellerId/$fileName');

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }
}
