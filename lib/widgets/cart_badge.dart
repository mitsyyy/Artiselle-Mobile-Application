import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/router.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().itemCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
        ),
        if (count > 0)
          Positioned(
            right: 4, top: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: Text('$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
      ],
    );
  }
}
