import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String orderId;
  final String buyerId;
  final String buyerDisplayName;
  final int rating; // 1–5
  final String feedback;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.buyerId,
    required this.buyerDisplayName,
    required this.rating,
    required this.feedback,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'orderId': orderId,
        'buyerId': buyerId,
        'buyerDisplayName': buyerDisplayName,
        'rating': rating,
        'feedback': feedback,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) =>
      ReviewModel(
        id: id,
        productId: map['productId'] as String,
        orderId: map['orderId'] as String,
        buyerId: map['buyerId'] as String,
        buyerDisplayName: map['buyerDisplayName'] as String? ?? 'Anonymous',
        rating: (map['rating'] as num).toInt(),
        feedback: map['feedback'] as String? ?? '',
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}
