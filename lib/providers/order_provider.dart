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
];

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = List.from(_seedOrders);

  List<OrderModel> ordersForBuyer(String buyerId) {
    final list = _orders.where((o) => o.buyerId == buyerId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
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
