import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/router.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().getById(orderId);
    if (order == null) {
      return const Scaffold(body: Center(child: Text('Order not found.')));
    }

    final (statusLabel, statusColor) = switch (order.status) {
      ShipmentStatus.pending => ('Pending', Colors.orange),
      ShipmentStatus.processing => ('Processing', Colors.blue),
      ShipmentStatus.shipped => ('Shipped', Colors.indigo),
      ShipmentStatus.delivered => ('Delivered', Colors.green),
      ShipmentStatus.cancelled => ('Cancelled', Colors.red),
    };

    final buyerId = context.read<AuthProvider>().currentUser!.uid;
    final canReview = order.status == ShipmentStatus.delivered;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Row(children: [
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Chip(
                label: Text(statusLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: statusColor,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ]),
            const SizedBox(height: 4),
            Text('Order ID: $orderId', style: const TextStyle(color: Colors.grey)),
            Text('Placed: ${order.createdAt.toLocal().toString().split('.').first}',
                style: const TextStyle(color: Colors.grey)),
            const Divider(height: 24),
            // Items
            Text('Items', style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                if (item.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(item.imageUrl!, width: 48, height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(width: 48, height: 48)),
                  ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('₱${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}'),
                  ],
                )),
                Text('₱${item.subtotal.toStringAsFixed(2)}'),
              ]),
            )),
            const Divider(height: 24),
            // Total
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('₱${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
                      color: Theme.of(context).colorScheme.primary)),
            ]),
            const Divider(height: 24),
            // Shipping
            Text('Shipping Address', style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(order.shippingAddress),
            const SizedBox(height: 12),
            Text('Payment: ${order.paymentMethod}',
                style: const TextStyle(color: Colors.grey)),
            // Review button
            if (canReview) ...[
              const Divider(height: 24),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.rate_review_outlined),
                  label: Text('Review: ${item.productTitle}'),
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.writeReview,
                      arguments: {
                        'productId': item.productId,
                        'orderId': orderId,
                        'buyerId': buyerId,
                      }),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
