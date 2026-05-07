import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import '../models/store_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Users ─────────────────────────────────────────────────────────────────────

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ── Products ──────────────────────────────────────────────────────────────────

  /// Fetch all active products, ordered by creation date (newest first).
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Fetch products by a specific seller.
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    final snapshot = await _db
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Fetch a single product by ID.
  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ProductModel.fromMap(doc.id, doc.data()!);
  }

  /// Add a new product. Returns the generated document ID.
  Future<String> addProduct(ProductModel product) async {
    final docRef = await _db.collection('products').add(product.toMap());
    return docRef.id;
  }

  /// Update an existing product.
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _db.collection('products').doc(productId).update(data);
  }

  /// Delete a product.
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // ── Orders ────────────────────────────────────────────────────────────────────

  /// Fetch orders for a buyer, newest first.
  Future<List<OrderModel>> getOrdersForBuyer(String buyerId) async {
    final snapshot = await _db
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Fetch orders for a seller, newest first.
  Future<List<OrderModel>> getOrdersForSeller(String sellerId) async {
    final snapshot = await _db
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Fetch a single order by ID.
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _db.collection('orders').doc(orderId).get();
    if (!doc.exists || doc.data() == null) return null;
    return OrderModel.fromMap(doc.id, doc.data()!);
  }

  /// Create a new order. Returns the generated document ID.
  Future<String> createOrder(OrderModel order) async {
    final docRef = await _db.collection('orders').add(order.toMap());
    return docRef.id;
  }

  /// Update order status.
  Future<void> updateOrderStatus(String orderId, ShipmentStatus status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status.name,
    });
  }

  // ── Reviews ───────────────────────────────────────────────────────────────────

  /// Fetch reviews for a product.
  Future<List<ReviewModel>> getReviewsForProduct(String productId) async {
    final snapshot = await _db
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Add a review and update the product's average rating.
  Future<void> addReview(ReviewModel review) async {
    // Add the review document
    await _db.collection('reviews').add(review.toMap());

    // Recalculate rating for the product
    final reviews = await getReviewsForProduct(review.productId);
    if (reviews.isNotEmpty) {
      final avg =
          reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      await _db.collection('products').doc(review.productId).update({
        'averageRating': avg,
        'reviewCount': reviews.length,
      });
    }
  }

  // ── Stores ────────────────────────────────────────────────────────────────────

  /// Fetch a store profile by seller UID.
  Future<StoreModel?> getStore(String sellerId) async {
    final doc = await _db.collection('stores').doc(sellerId).get();
    if (!doc.exists || doc.data() == null) return null;
    return StoreModel.fromMap(doc.id, doc.data()!);
  }

  /// Create or update a store profile.
  Future<void> saveStore(StoreModel store) async {
    await _db.collection('stores').doc(store.uid).set(store.toMap());
  }
}
