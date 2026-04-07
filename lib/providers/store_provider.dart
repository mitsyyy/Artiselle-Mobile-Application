import 'package:flutter/material.dart';
import '../models/store_model.dart';

final _seedStores = {
  'static-seller-001': StoreModel(
    uid: 'static-seller-001',
    storeName: 'My Artisan Shop',
    description: 'Handmade goods with love.',
    contactInfo: 'seller@artiselle.com',
  ),
};

class StoreProvider extends ChangeNotifier {
  final Map<String, StoreModel> _stores = Map.from(_seedStores);

  StoreModel? getStore(String sellerId) => _stores[sellerId];

  /// Returns null on success, or an error message.
  String? saveStore({
    required String sellerId,
    required String storeName,
    required String description,
    String? profileImageUrl,
    String? contactInfo,
  }) {
    if (storeName.trim().isEmpty) return 'Store name is required.';
    if (description.trim().isEmpty) return 'Description is required.';

    _stores[sellerId] = StoreModel(
      uid: sellerId,
      storeName: storeName.trim(),
      description: description.trim(),
      profileImageUrl: profileImageUrl,
      contactInfo: contactInfo?.trim(),
    );
    notifyListeners();
    return null;
  }
}
