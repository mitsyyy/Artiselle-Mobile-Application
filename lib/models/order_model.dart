import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productTitle': productTitle,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] as String? ?? '',
        productTitle: map['productTitle'] as String? ?? 'Unknown Product',
        unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        imageUrl: map['imageUrl'] as String?,
      );
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

  Map<String, dynamic> toMap() => {
        'buyerId': buyerId,
        'sellerId': sellerId,
        'items': items.map((i) => i.toMap()).toList(),
        'totalAmount': totalAmount,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.parse(d);
      return DateTime.now();
    }

    return OrderModel(
      id: id,
      buyerId: map['buyerId'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: map['shippingAddress'] as String? ?? 'No address provided',
      paymentMethod: map['paymentMethod'] as String? ?? 'Unknown',
      status: ShipmentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ShipmentStatus.pending,
      ),
      createdAt: parseDate(map['createdAt']),
    );
  }

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
