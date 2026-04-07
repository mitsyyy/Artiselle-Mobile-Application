import 'package:flutter/material.dart';
import '../models/order_model.dart';

final _seedOrders = [
  OrderModel(
    id: 'order-seed-001',
    buyerId: 'static-buyer-001',
    sellerId: 'seller-1',
    items: [
      const OrderItem(
        productId: 'prod-1',
        productTitle: 'Hand-woven Basket',
        unitPrice: 450.00,
        quantity: 1,
        imageUrl: 'https://picsum.photos/seed/basket/400/400',
      ),
    ],
    totalAmount: 450.00,
    shippingAddress: '123 Test St, Cebu City, 6000',
    paymentMethod: 'GCash',
    status: ShipmentStatus.delivered,
    createdAt: DateTime(2024, 4, 1),
  ),
  OrderModel(
    id: 'order-seed-002',
    buyerId: 'static-buyer-001',
    sellerId: 'static-seller-001',
    items: [
      const OrderItem(
        productId: 'prod-1',
        productTitle: 'Hand-woven Basket',
        unitPrice: 450.00,
        quantity: 2,
        imageUrl: 'https://picsum.photos/seed/basket/400/400',
      ),
    ],
    totalAmount: 900.00,
    shippingAddress: '456 Sample Ave, Manila, 1000',
    paymentMethod: 'PayPal',
    status: ShipmentStatus.pending,
    createdAt: DateTime(2026, 4, 1),
  ),
  OrderModel(
    id: 'order-seed-003',
    buyerId: 'static-buyer-001',
    sellerId: 'static-seller-001',
    items: [
      const OrderItem(
        productId: 'prod-2',
        productTitle: 'Embroidered Tote Bag',
        unitPrice: 320.00,
        quantity: 1,
        imageUrl: 'https://picsum.photos/seed/tote/400/400',
      ),
    ],
    totalAmount: 320.00,
    shippingAddress: '789 Demo Rd, Davao City, 8000',
    paymentMethod: 'GCash',
    status: ShipmentStatus.shipped,
    createdAt: DateTime(2026, 3, 28),
  ),
];

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = List.from(_seedOrders);

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

  void updateStatus(String orderId, ShipmentStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: status);
    notifyListeners();
  }

  OrderModel? getById(String id) {
    try { return _orders.firstWhere((o) => o.id == id); } catch (_) { return null; }
  }

  /// Returns the created order.
  OrderModel placeOrder({
    required String buyerId,
    required String sellerId,
    required List<OrderItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  }) {
    final order = OrderModel(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      buyerId: buyerId,
      sellerId: sellerId,
      items: items,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      status: ShipmentStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.add(order);
    notifyListeners();
    return order;
  }

  bool hasDeliveredOrderForProduct(String buyerId, String productId) {
    return _orders.any((o) =>
        o.buyerId == buyerId &&
        o.status == ShipmentStatus.delivered &&
        o.items.any((i) => i.productId == productId));
  }

  String? getOrderIdForReview(String buyerId, String productId) {
    try {
      return _orders.firstWhere((o) =>
          o.buyerId == buyerId &&
          o.status == ShipmentStatus.delivered &&
          o.items.any((i) => i.productId == productId)).id;
    } catch (_) { return null; }
  }
}
