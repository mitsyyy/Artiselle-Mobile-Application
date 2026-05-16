import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../utils/router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<Map<String, dynamic>> _fetchStats() async {
    int usersCount = 0;
    int productsCount = 0;
    int ordersCount = 0;

    try {
      final uSnap = await FirebaseFirestore.instance.collection('users').count().get();
      usersCount = uSnap.count ?? 0;
      
      final pSnap = await FirebaseFirestore.instance.collection('products').count().get();
      productsCount = pSnap.count ?? 0;
      
      final oSnap = await FirebaseFirestore.instance.collection('orders').count().get();
      ordersCount = oSnap.count ?? 0;
    } catch (e) {
      // Fallback if count() is not supported or fails
      final uSnap = await FirebaseFirestore.instance.collection('users').get();
      usersCount = uSnap.size;
      final pSnap = await FirebaseFirestore.instance.collection('products').get();
      productsCount = pSnap.size;
      final oSnap = await FirebaseFirestore.instance.collection('orders').get();
      ordersCount = oSnap.size;
    }
    
    return {
      'users': usersCount,
      'products': productsCount,
      'orders': ordersCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.deepPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.admin_panel_settings, size: 100, color: Colors.white24),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final stats = snapshot.data ?? {'users': 0, 'products': 0, 'orders': 0};
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Platform Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(context, 'Total Users', '${stats['users']}', Icons.people_outline, Colors.deepPurpleAccent)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatCard(context, 'Products', '${stats['products']}', Icons.inventory_2_outlined, Colors.purpleAccent)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: _buildStatCard(context, 'Total Orders', '${stats['orders']}', Icons.shopping_bag_outlined, Colors.deepPurple),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text('Management Tools', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildActionCard(
                  context,
                  title: 'Users',
                  icon: Icons.manage_accounts,
                  color: Colors.deepPurpleAccent,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                ),
                _buildActionCard(
                  context,
                  title: 'Products',
                  icon: Icons.inventory_2,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminProducts),
                ),
                _buildActionCard(
                  context,
                  title: 'Orders',
                  icon: Icons.local_shipping,
                  color: Colors.indigoAccent,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.adminOrders),
                ),
                _buildActionCard(
                  context,
                  title: 'Settings',
                  icon: Icons.settings,
                  color: Colors.deepPurple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
