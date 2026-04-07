import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';

enum _Period { week, month, allTime }

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  _Period _period = _Period.allTime;

  List<OrderModel> _filtered(List<OrderModel> orders) {
    final now = DateTime.now();
    return orders.where((o) {
      if (_period == _Period.week) {
        return o.createdAt.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_period == _Period.month) {
        return o.createdAt.isAfter(now.subtract(const Duration(days: 30)));
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sellerId = context.watch<AuthProvider>().currentUser?.uid ?? '';
    final allOrders = context.watch<OrderProvider>().ordersForSeller(sellerId);
    final products = context.watch<ProductProvider>().getBySellerAll(sellerId);
    final orders = _filtered(allOrders);

    final totalRevenue = orders.fold<double>(0, (s, o) => s + o.totalAmount);
    final totalOrders = orders.length;

    // Per-product breakdown
    final Map<String, int> unitsSold = {};
    final Map<String, double> revenueByProduct = {};
    for (final order in orders) {
      for (final item in order.items) {
        unitsSold[item.productId] =
            (unitsSold[item.productId] ?? 0) + item.quantity;
        revenueByProduct[item.productId] =
            (revenueByProduct[item.productId] ?? 0) + item.subtotal;
      }
    }

    // Sort by revenue desc
    final productIds = revenueByProduct.keys.toList()
      ..sort((a, b) =>
          (revenueByProduct[b] ?? 0).compareTo(revenueByProduct[a] ?? 0));

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period selector
          SegmentedButton<_Period>(
            segments: const [
              ButtonSegment(value: _Period.week, label: Text('Last 7 days')),
              ButtonSegment(value: _Period.month, label: Text('Last 30 days')),
              ButtonSegment(value: _Period.allTime, label: Text('All time')),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 24),

          // Summary
          Row(
            children: [
              _MetricCard(
                  label: 'Total Revenue',
                  value: '₱${totalRevenue.toStringAsFixed(2)}'),
              const SizedBox(width: 12),
              _MetricCard(
                  label: 'Total Orders', value: '$totalOrders'),
            ],
          ),
          const SizedBox(height: 24),

          Text('Product Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          if (productIds.isEmpty)
            const Text('No sales data for this period.',
                style: TextStyle(color: Colors.grey))
          else
            ...productIds.map((pid) {
              final product = products.firstWhere(
                (p) => p.id == pid,
                orElse: () => products.isNotEmpty
                    ? products.first
                    : throw StateError('no products'),
              );
              final title = product.title;
              final units = unitsSold[pid] ?? 0;
              final rev = revenueByProduct[pid] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('$units unit(s) sold'),
                  trailing: Text(
                    '₱${rev.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
