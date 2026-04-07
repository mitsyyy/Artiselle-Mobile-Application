import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/router.dart';
import '../../widgets/cart_badge.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/star_rating.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().getById(productId);
    if (product == null) {
      return const Scaffold(body: Center(child: Text('Product not found.')));
    }
    final reviews = context.watch<ProductProvider>().getReviews(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: const [CartBadge()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                product.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFFE0D8D0),
                        child: Icon(Icons.image_not_supported, size: 60)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & price
                  Text(product.title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₱${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Rating
                  Row(children: [
                    StarRating(rating: product.averageRating),
                    const SizedBox(width: 6),
                    Text('${product.averageRating.toStringAsFixed(1)} '
                        '(${product.reviewCount} reviews)',
                        style: const TextStyle(color: Colors.grey)),
                  ]),
                  const SizedBox(height: 8),
                  // Store
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.storeProfile,
                        arguments: product.sellerId),
                    child: Row(children: [
                      const Icon(Icons.storefront_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(product.sellerStoreName,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline)),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  // Stock
                  product.isOutOfStock
                      ? const Text('Out of Stock',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600))
                      : Text('${product.stock} in stock',
                          style: const TextStyle(color: Colors.green)),
                  const Divider(height: 24),
                  // Description
                  Text('Description',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.description),
                  const Divider(height: 24),
                  // Reviews
                  Text('Reviews',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    const Text('No reviews yet.', style: TextStyle(color: Colors.grey))
                  else
                    ...reviews.map((r) => ReviewTile(review: r)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: product.isOutOfStock
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    final msg = context.read<CartProvider>().addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(msg ?? 'Added to cart'),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                ),
              ),
            ),
    );
  }
}
