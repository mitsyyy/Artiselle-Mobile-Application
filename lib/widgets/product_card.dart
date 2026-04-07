import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/router.dart';
import 'star_rating.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail,
          arguments: product.id),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                Image.network(
                  product.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Color(0xFFE0D8D0),
                          child: Icon(Icons.image_not_supported, size: 40)),
                ),
                if (product.isOutOfStock)
                  Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: const Text('Out of Stock',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('₱${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(children: [
                    StarRating(rating: product.averageRating, size: 12),
                    const SizedBox(width: 4),
                    Text('(${product.reviewCount})',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
