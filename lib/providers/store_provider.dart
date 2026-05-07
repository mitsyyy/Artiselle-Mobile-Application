import 'package:flutter/material.dart';
import '../models/store_model.dart';
import '../services/firestore_service.dart';

class StoreProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  final Map<String, StoreModel> _stores = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  StoreModel? getStore(String sellerId) => _stores[sellerId];

  /// Fetch a store profile from Firestore and cache it locally.
  Future<StoreModel?> loadStore(String sellerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final store = await _firestoreService.getStore(sellerId);
      if (store != null) {
        _stores[sellerId] = store;
      }
      _isLoading = false;
      notifyListeners();
      return store;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Save (create or update) a store profile. Returns null on success, error message on failure.
  Future<String?> saveStore({
    required String sellerId,
    required String storeName,
    required String description,
    String? profileImageUrl,
    String? contactInfo,
  }) async {
    if (storeName.trim().isEmpty) return 'Store name is required.';
    if (description.trim().isEmpty) return 'Description is required.';

    final store = StoreModel(
      uid: sellerId,
      storeName: storeName.trim(),
      description: description.trim(),
      profileImageUrl: profileImageUrl,
      contactInfo: contactInfo?.trim(),
    );

    try {
      await _firestoreService.saveStore(store);
      _stores[sellerId] = store;
      notifyListeners();
      return null;
    } catch (_) {
      return 'Failed to save store. Please try again.';
    }
  }
}
