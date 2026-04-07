import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/router.dart';
import '../../widgets/cart_badge.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/product_card.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.filteredProducts;
    final selectedCat = productProvider.selectedCategoryId;
    final sortBy = productProvider.sortBy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artiselle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
          ),
          const CartBadge(),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.accountSettings),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: selectedCat == null,
                    onSelected: (_) => context.read<ProductProvider>().setCategory(null),
                  ),
                ),
                ...kStaticCategories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.name),
                    selected: selectedCat == cat.id,
                    onSelected: (_) =>
                        context.read<ProductProvider>().setCategory(
                            selectedCat == cat.id ? null : cat.id),
                  ),
                )),
              ],
            ),
          ),
          // Sort row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('${products.length} items',
                    style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                DropdownButton<String>(
                  value: sortBy,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(value: 'price_asc', child: Text('Price ↑')),
                    DropdownMenuItem(value: 'price_desc', child: Text('Price ↓')),
                  ],
                  onChanged: (v) =>
                      context.read<ProductProvider>().setSort(v ?? 'newest'),
                ),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No products found.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => ProductCard(product: products[i]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, AppRoutes.orders);
          if (i == 2) Navigator.pushNamed(context, AppRoutes.accountSettings);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}
