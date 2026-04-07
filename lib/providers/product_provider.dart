import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

final _seedProducts = [
  ProductModel(
    id: 'prod-1', sellerId: 'seller-1', sellerStoreName: 'Crafty Corner',
    title: 'Hand-woven Basket',
    description: 'A beautiful hand-woven basket made from natural rattan. Perfect for storage or decoration.',
    price: 450.00, categoryId: 'cat-1', stock: 10,
    imageUrls: ['https://picsum.photos/seed/basket/400/400'],
    createdAt: DateTime(2024, 3, 1), averageRating: 4.5, reviewCount: 8,
  ),
  ProductModel(
    id: 'prod-2', sellerId: 'seller-1', sellerStoreName: 'Crafty Corner',
    title: 'Embroidered Tote Bag',
    description: 'Handmade tote bag with floral embroidery. Eco-friendly canvas material.',
    price: 320.00, categoryId: 'cat-2', stock: 5,
    imageUrls: ['https://picsum.photos/seed/tote/400/400'],
    createdAt: DateTime(2024, 3, 5), averageRating: 4.8, reviewCount: 12,
  ),
  ProductModel(
    id: 'prod-3', sellerId: 'seller-2', sellerStoreName: 'The Book Nook',
    title: 'Local Poetry Collection',
    description: 'A self-published collection of poems celebrating Filipino culture and nature.',
    price: 180.00, categoryId: 'cat-3', stock: 20,
    imageUrls: ['https://picsum.photos/seed/book/400/400'],
    createdAt: DateTime(2024, 3, 10), averageRating: 4.2, reviewCount: 5,
  ),
  ProductModel(
    id: 'prod-4', sellerId: 'seller-3', sellerStoreName: 'Silver & Stone',
    title: 'Handcrafted Silver Ring',
    description: 'Sterling silver ring with a natural stone setting. Each piece is unique.',
    price: 850.00, categoryId: 'cat-4', stock: 3,
    imageUrls: ['https://picsum.photos/seed/ring/400/400'],
    createdAt: DateTime(2024, 3, 12), averageRating: 5.0, reviewCount: 3,
  ),
  ProductModel(
    id: 'prod-5', sellerId: 'seller-3', sellerStoreName: 'Silver & Stone',
    title: 'Watercolor Art Print',
    description: 'Original watercolor print of a Philippine landscape. Signed by the artist.',
    price: 600.00, categoryId: 'cat-5', stock: 0,
    imageUrls: ['https://picsum.photos/seed/art/400/400'],
    createdAt: DateTime(2024, 3, 15), averageRating: 4.7, reviewCount: 6,
  ),
  ProductModel(
    id: 'prod-6', sellerId: 'seller-2', sellerStoreName: 'The Book Nook',
    title: 'Handmade Journal',
    description: 'Leather-bound journal with handmade paper pages. Great for sketching or writing.',
    price: 275.00, categoryId: 'cat-1', stock: 15,
    imageUrls: ['https://picsum.photos/seed/journal/400/400'],
    createdAt: DateTime(2024, 3, 18), averageRating: 4.6, reviewCount: 9,
  ),
  ProductModel(
    id: 'prod-7', sellerId: 'static-seller-001', sellerStoreName: 'My Artisan Shop',
    title: 'Hand-woven Basket',
    description: 'A beautiful hand-woven basket made from natural rattan.',
    price: 450.00, categoryId: 'cat-1', stock: 10,
    imageUrls: ['https://picsum.photos/seed/basket/400/400'],
    createdAt: DateTime(2026, 3, 1), averageRating: 4.5, reviewCount: 2,
  ),
  ProductModel(
    id: 'prod-8', sellerId: 'static-seller-001', sellerStoreName: 'My Artisan Shop',
    title: 'Embroidered Tote Bag',
    description: 'Handmade tote bag with floral embroidery. Eco-friendly canvas material.',
    price: 320.00, categoryId: 'cat-2', stock: 5,
    imageUrls: ['https://picsum.photos/seed/tote/400/400'],
    createdAt: DateTime(2026, 3, 5), averageRating: 4.8, reviewCount: 3,
  ),
];

final _seedReviews = <String, List<ReviewModel>>{
  'prod-1': [
    ReviewModel(
      id: 'rev-1', productId: 'prod-1', orderId: 'order-old-1',
      buyerId: 'buyer-x', buyerDisplayName: 'Maria S.', rating: 5,
      feedback: 'Absolutely love this basket! Great quality.',
      createdAt: DateTime(2024, 3, 20),
    ),
    ReviewModel(
      id: 'rev-2', productId: 'prod-1', orderId: 'order-old-2',
      buyerId: 'buyer-y', buyerDisplayName: 'Juan D.', rating: 4,
      feedback: 'Very well made. Shipping was fast too.',
      createdAt: DateTime(2024, 3, 22),
    ),
  ],
};

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = List.from(_seedProducts);
  final Map<String, List<ReviewModel>> _reviews = Map.from(_seedReviews);

  String _searchQuery = '';
  String? _selectedCategoryId;
  String _sortBy = 'newest';

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

  void addProduct(ProductModel product) {
    _products = [product, ..._products];
    notifyListeners();
  }

  void updateProduct(ProductModel updated) {
    _products = _products.map((p) => p.id == updated.id ? updated : p).toList();
    notifyListeners();
  }

  void deleteProduct(String productId) {
    _products = _products.where((p) => p.id != productId).toList();
    notifyListeners();
  }

  void toggleActive(String productId) {
    _products = _products.map((p) {
      if (p.id == productId) return p.copyWith(isActive: !p.isActive);
      return p;
    }).toList();
    notifyListeners();
  }

  void updateStock(String productId, int newStock) {
    _products = _products.map((p) {
      if (p.id == productId) return p.copyWith(stock: newStock);
      return p;
    }).toList();
    notifyListeners();
  }

  // ── Review method ────────────────────────────────────────────────────────────

  void addReview(ReviewModel review) {
    _reviews[review.productId] = [
      ...(_reviews[review.productId] ?? []),
      review,
    ];
    final reviews = _reviews[review.productId]!;
    final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
    _products = _products.map((p) {
      if (p.id == review.productId) {
        return p.copyWith(averageRating: avg, reviewCount: reviews.length);
      }
      return p;
    }).toList();
    notifyListeners();
  }
}
