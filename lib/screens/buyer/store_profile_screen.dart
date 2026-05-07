import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/store_provider.dart';
import '../../widgets/cart_badge.dart';
import '../../widgets/product_card.dart';

class StoreProfileScreen extends StatefulWidget {
  final String sellerId;
  const StoreProfileScreen({super.key, required this.sellerId});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load store profile from Firestore
    Future.microtask(() {
      context.read<StoreProvider>().loadStore(widget.sellerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>().getStore(widget.sellerId);
    final products = context.watch<ProductProvider>().getByStore(widget.sellerId);

    return Scaffold(
      appBar: AppBar(
        title: Text(store?.storeName ?? 'Store'),
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
                      backgroundImage: store?.profileImageUrl != null
                          ? NetworkImage(store!.profileImageUrl!)
                          : null,
                      child: store?.profileImageUrl == null
                          ? Text(
                              (store?.storeName ?? 'S')[0],
                              style: TextStyle(fontSize: 24,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(store?.storeName ?? 'Unknown Store',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text(store?.description ?? '',
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
