enum ShipmentStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final String productId;
  final String productTitle;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;

  const OrderItem({
    required this.productId,
    required this.productTitle,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
  });

  double get subtotal => unitPrice * quantity;
}

class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final ShipmentStatus status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  OrderModel copyWith({ShipmentStatus? status}) => OrderModel(
        id: id,
        buyerId: buyerId,
        sellerId: sellerId,
        items: items,
        totalAmount: totalAmount,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
