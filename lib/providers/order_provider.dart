import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Load orders for a buyer from Firestore.
  Future<void> loadOrdersForBuyer(String buyerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _firestoreService.getOrdersForBuyer(buyerId);
    } catch (_) {
      // Silently fail
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load orders for a seller from Firestore.
  Future<void> loadOrdersForSeller(String sellerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _firestoreService.getOrdersForSeller(sellerId);
    } catch (_) {
      // Silently fail
    }

    _isLoading = false;
    notifyListeners();
  }

  List<OrderModel> ordersForBuyer(String buyerId) {
    final list = _orders.where((o) => o.buyerId == buyerId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<OrderModel> ordersForSeller(String sellerId) {
    final list = _orders.where((o) => o.sellerId == sellerId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> updateStatus(String orderId, ShipmentStatus status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _orders[idx] = _orders[idx].copyWith(status: status);
        notifyListeners();
      }
    } catch (_) {
      rethrow;
    }
  }

  OrderModel? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Place a new order. Returns the created order with Firestore ID.
  Future<OrderModel> placeOrder({
    required String buyerId,
    required String sellerId,
    required List<OrderItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    final order = OrderModel(
      id: '', // Will be replaced by Firestore ID
      buyerId: buyerId,
      sellerId: sellerId,
      items: items,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      status: ShipmentStatus.pending,
      createdAt: DateTime.now(),
    );

    final docId = await _firestoreService.createOrder(order);

    final createdOrder = OrderModel(
      id: docId,
      buyerId: buyerId,
      sellerId: sellerId,
      items: items,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      status: ShipmentStatus.pending,
      createdAt: order.createdAt,
    );

    _orders.insert(0, createdOrder);
    notifyListeners();
    return createdOrder;
  }

  bool hasDeliveredOrderForProduct(String buyerId, String productId) {
    return _orders.any((o) =>
        o.buyerId == buyerId &&
        o.status == ShipmentStatus.delivered &&
        o.items.any((i) => i.productId == productId));
  }

  String? getOrderIdForReview(String buyerId, String productId) {
    try {
      return _orders
          .firstWhere((o) =>
              o.buyerId == buyerId &&
              o.status == ShipmentStatus.delivered &&
              o.items.any((i) => i.productId == productId))
          .id;
    } catch (_) {
      return null;
    }
  }
}
