import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _products = [];
  final Map<String, List<ReviewModel>> _reviews = {};
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  String? _selectedCategoryId;
  String _sortBy = 'newest';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String get sortBy => _sortBy;

  List<ProductModel> get filteredProducts {
    var list = _products.where((p) => p.isActive).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  /// Load all products from Firestore.
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _firestoreService.getProducts();
    } catch (e) {
      _error = 'Failed to load products.';
    }

    _isLoading = false;
    notifyListeners();
  }

  ProductModel? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProductModel> getByStore(String sellerId) =>
      _products.where((p) => p.sellerId == sellerId && p.isActive).toList();

  List<ReviewModel> getReviews(String productId) =>
      _reviews[productId] ?? [];

  /// Load reviews for a specific product from Firestore.
  Future<void> loadReviews(String productId) async {
    try {
      final reviews = await _firestoreService.getReviewsForProduct(productId);
      _reviews[productId] = reviews;
      notifyListeners();
    } catch (_) {
      // Silently fail
    }
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSort(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  // ── Seller methods ──────────────────────────────────────────────────────────

  List<ProductModel> getBySellerAll(String sellerId) =>
      _products.where((p) => p.sellerId == sellerId).toList();

  /// Load products for a specific seller from Firestore.
  Future<void> loadSellerProducts(String sellerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sellerProducts =
          await _firestoreService.getProductsBySeller(sellerId);
      // Merge: remove old seller products from list, add new ones
      _products.removeWhere((p) => p.sellerId == sellerId);
      _products.addAll(sellerProducts);
    } catch (_) {
      // Silently fail
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      final docId = await _firestoreService.addProduct(product);
      // Add to local list with the Firestore-generated ID
      final newProduct = ProductModel(
        id: docId,
        sellerId: product.sellerId,
        sellerStoreName: product.sellerStoreName,
        title: product.title,
        description: product.description,
        price: product.price,
        categoryId: product.categoryId,
        stock: product.stock,
        imageUrls: product.imageUrls,
        isActive: product.isActive,
        createdAt: product.createdAt,
        averageRating: product.averageRating,
        reviewCount: product.reviewCount,
      );
      _products = [newProduct, ..._products];
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel updated) async {
    try {
      await _firestoreService.updateProduct(updated.id, updated.toMap());
      _products =
          _products.map((p) => p.id == updated.id ? updated : p).toList();
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestoreService.deleteProduct(productId);
      _products = _products.where((p) => p.id != productId).toList();
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> toggleActive(String productId) async {
    final product = getById(productId);
    if (product == null) return;
    final updated = product.copyWith(isActive: !product.isActive);
    await updateProduct(updated);
  }

  Future<void> updateStock(String productId, int newStock) async {
    final product = getById(productId);
    if (product == null) return;
    final updated = product.copyWith(stock: newStock);
    await updateProduct(updated);
  }

  // ── Review method ────────────────────────────────────────────────────────────

  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestoreService.addReview(review);
      // Refresh reviews and product data
      await loadReviews(review.productId);
      // Refresh the product to get updated rating
      final updatedProduct =
          await _firestoreService.getProduct(review.productId);
      if (updatedProduct != null) {
        _products = _products
            .map((p) => p.id == review.productId ? updatedProduct : p)
            .toList();
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }
}
