import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/cart_badge.dart';
import '../../widgets/product_card.dart';

// Static store data keyed by sellerId
final _staticStores = {
  'seller-1': {'name': 'Crafty Corner', 'description': 'Handmade goods with love from Cebu.'},
  'seller-2': {'name': 'The Book Nook', 'description': 'Independent books and journals.'},
  'seller-3': {'name': 'Silver & Stone', 'description': 'Artisan jewelry and fine art prints.'},
};

class StoreProfileScreen extends StatelessWidget {
  final String sellerId;
  const StoreProfileScreen({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final store = _staticStores[sellerId];
    final products = context.watch<ProductProvider>().getByStore(sellerId);

    return Scaffold(
      appBar: AppBar(
        title: Text(store?['name'] ?? 'Store'),
        actions: const [CartBadge()],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        (store?['name'] ?? 'S')[0],
                        style: TextStyle(fontSize: 24,
                            color: Theme.of(context).colorScheme.onPrimaryContainer),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store?['name'] ?? 'Unknown Store',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text(store?['description'] ?? '',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    )),
                  ]),
                  const Divider(height: 24),
                  Text('Products (${products.length})',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(product: products[i]),
                childCount: products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
