import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/router.dart';

class SellerOrdersScreen extends StatelessWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId = context.watch<AuthProvider>().currentUser?.uid ?? '';
    final orders = context.watch<OrderProvider>().ordersForSeller(sellerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Orders')),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, i) => _OrderTile(order: orders[i]),
            ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text('Order #${order.id.split('-').last}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.items.length} item(s)  •  ₱${order.totalAmount.toStringAsFixed(2)}'),
            Text(
              _formatDate(order.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: _StatusChip(status: order.status),
        onTap: () => Navigator.pushNamed(
            context, AppRoutes.sellerOrderDetail,
            arguments: order.id),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _StatusChip extends StatelessWidget {
  final ShipmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {
      ShipmentStatus.pending: Colors.orange,
      ShipmentStatus.processing: Colors.blue,
      ShipmentStatus.shipped: Colors.purple,
      ShipmentStatus.delivered: Colors.green,
      ShipmentStatus.cancelled: Colors.red,
    };
    return Chip(
      label: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
      backgroundColor: colors[status] ?? Colors.grey,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
