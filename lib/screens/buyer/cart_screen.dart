import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final item = items[i];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.product.imageUrls.first,
                          width: 64, height: 64, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(width: 64, height: 64,
                                  child: ColoredBox(color: Color(0xFFE0D8D0)))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.title,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('₱${item.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                    // Quantity controls
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (item.quantity <= 1) {
                            context.read<CartProvider>().removeItem(item.product.id);
                          } else {
                            context.read<CartProvider>()
                                .updateQuantity(item.product.id, item.quantity - 1);
                          }
                        },
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          final msg = context.read<CartProvider>()
                              .updateQuantity(item.product.id, item.quantity + 1);
                          if (msg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg),
                                    duration: const Duration(seconds: 2)));
                          }
                        },
                      ),
                    ]),
                  ],
                );
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('₱${cart.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.checkout),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48)),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
