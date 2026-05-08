import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/router.dart';

class SellerProductListScreen extends StatelessWidget {
  const SellerProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId =
        context.watch<AuthProvider>().currentUser?.uid ?? '';
    final products =
        context.watch<ProductProvider>().getBySellerAll(sellerId);

    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.addEditProduct),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products yet. Add your first one.'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: products.length,
              itemBuilder: (_, i) =>
                  _ProductTile(product: products[i]),
            ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProductProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            product.imageUrls.first,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported, size: 56),
          ),
        ),
        title: Text(product.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '₱${product.price.toStringAsFixed(2)}  •  Stock: ${product.stock}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active toggle
            Switch(
              value: product.isActive,
              onChanged: (_) => provider.toggleActive(product.id),
            ),
            // Edit
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.pushNamed(
                  context, AppRoutes.addEditProduct,
                  arguments: product.id),
            ),
            // Delete
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, provider, product),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ProductProvider provider, ProductModel product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.title}"? Order history will be kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.deleteProduct(product.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
