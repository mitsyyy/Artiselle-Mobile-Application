import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/store_provider.dart';
import '../../utils/router.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final sellerId = context.read<AuthProvider>().currentUser?.uid ?? '';
      if (sellerId.isNotEmpty) {
        context.read<ProductProvider>().loadSellerProducts(sellerId);
        context.read<OrderProvider>().loadOrdersForSeller(sellerId);
        context.read<StoreProvider>().loadStore(sellerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final sellerId = user?.uid ?? '';
    final orders = context.watch<OrderProvider>().ordersForSeller(sellerId);
    final products = context.watch<ProductProvider>().getBySellerAll(sellerId);
    final store = context.watch<StoreProvider>().getStore(sellerId);

    final totalRevenue = orders.fold<double>(0, (s, o) => s + o.totalAmount);
    final activeListings = products.where((p) => p.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(store?.storeName ?? 'My Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.accountSettings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(
            children: [
              _SummaryCard(
                label: 'Total Orders',
                value: '${orders.length}',
                icon: Icons.receipt_long_outlined,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                label: 'Revenue',
                value: '₱${totalRevenue.toStringAsFixed(2)}',
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryCard(
                label: 'Active Listings',
                value: '$activeListings',
                icon: Icons.storefront_outlined,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                label: 'Total Products',
                value: '${products.length}',
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick actions
          Text('Quick Actions',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.store_outlined,
            title: 'Manage Store Profile',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.manageStore),
          ),
          _ActionTile(
            icon: Icons.inventory_outlined,
            title: 'My Products',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.sellerProducts),
          ),
          _ActionTile(
            icon: Icons.receipt_outlined,
            title: 'Incoming Orders',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.sellerOrders),
          ),
          _ActionTile(
            icon: Icons.bar_chart_outlined,
            title: 'Sales Report',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.salesReport),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, AppRoutes.sellerOrders);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.accountSettings);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
