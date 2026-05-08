import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';

class SellerOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().getById(orderId);
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Detail')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id.split('-').last}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Shipping Address',
            child: Text(order.shippingAddress),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Items Ordered',
            child: Column(
              children: order.items.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(item.imageUrl!,
                              width: 48, height: 48, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(item.productTitle),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text('₱${item.subtotal.toStringAsFixed(2)}'),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Order Total',
            child: Text(
              '₱${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Update Shipment Status',
            child: _StatusSelector(order: order),
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final OrderModel order;
  const _StatusSelector({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();
    return Column(
      children: ShipmentStatus.values.map((status) {
        final label =
            status.name[0].toUpperCase() + status.name.substring(1);
        return RadioListTile<ShipmentStatus>(
          title: Text(label),
          value: status,
          groupValue: order.status,
          onChanged: (v) async {
            if (v != null) {
              await orderProvider.updateStatus(order.id, v);
              // Reload seller products so updated stock is visible
              if (context.mounted) {
                final sellerId =
                    context.read<AuthProvider>().currentUser?.uid ?? '';
                if (sellerId.isNotEmpty) {
                  context.read<ProductProvider>().loadSellerProducts(sellerId);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status updated to $label')),
                );
              }
            }
          },
        );
      }).toList(),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[600])),
        const SizedBox(height: 8),
        child,
        const Divider(height: 24),
      ],
    );
  }
}
