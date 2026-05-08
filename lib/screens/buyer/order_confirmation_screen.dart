import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/router.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.read<OrderProvider>().getById(orderId);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              Text('Order Placed!',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Order ID: $orderId',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              if (order != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...order.items.map((i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${i.productTitle} x${i.quantity}',
                                  overflow: TextOverflow.ellipsis)),
                              Text('₱${i.subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                        )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('₱${order.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(child: Text(order.shippingAddress,
                              style: const TextStyle(color: Colors.grey))),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.buyerHome, (_) => false),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Continue Shopping'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.orders),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('View My Orders'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
