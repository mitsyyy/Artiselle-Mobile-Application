class ProductModel {
  final String id;
  final String sellerId;
  final String sellerStoreName;
  final String title;
  final String description;
  final double price;
  final String categoryId;
  final int stock;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;
  final double averageRating;
  final int reviewCount;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerStoreName,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.stock,
    required this.imageUrls,
    this.isActive = true,
    required this.createdAt,
    this.averageRating = 0,
    this.reviewCount = 0,
  });

  bool get isOutOfStock => stock <= 0;

  ProductModel copyWith({
    String? title,
    String? description,
    double? price,
    String? categoryId,
    int? stock,
    List<String>? imageUrls,
    bool? isActive,
    double? averageRating,
    int? reviewCount,
  }) {
    return ProductModel(
      id: id,
      sellerId: sellerId,
      sellerStoreName: sellerStoreName,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
