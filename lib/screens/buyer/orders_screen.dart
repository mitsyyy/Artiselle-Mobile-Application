import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/router.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        context.read<OrderProvider>().loadOrdersForBuyer(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().currentUser!.uid;
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.ordersForBuyer(uid);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders yet.'))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<OrderProvider>().loadOrdersForBuyer(uid),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final order = orders[i];
                      return Card(
                        child: ListTile(
                          title: Text('Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${order.items.length} item(s) · ₱${order.totalAmount.toStringAsFixed(2)}'),
                          trailing: _StatusChip(status: order.status),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.orderDetail,
                              arguments: order.id),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ShipmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ShipmentStatus.pending => ('Pending', Colors.orange),
      ShipmentStatus.processing => ('Processing', Colors.blue),
      ShipmentStatus.shipped => ('Shipped', Colors.indigo),
      ShipmentStatus.delivered => ('Delivered', Colors.green),
      ShipmentStatus.cancelled => ('Cancelled', Colors.red),
    };
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
