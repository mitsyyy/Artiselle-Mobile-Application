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
}
