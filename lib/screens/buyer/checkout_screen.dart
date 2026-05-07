import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/router.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _paymentMethod = 'GCash';
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    // Validate stock
    final outOfStock = cart.items.where((i) => i.product.isOutOfStock).toList();
    if (outOfStock.isNotEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${outOfStock.first.product.title} is out of stock. Remove it to continue.'),
      ));
      return;
    }

    try {
      final sellerId = cart.items.first.product.sellerId;
      final order = await orderProvider.placeOrder(
        buyerId: auth.currentUser!.uid,
        sellerId: sellerId,
        items: cart.items.map((i) => OrderItem(
          productId: i.product.id,
          productTitle: i.product.title,
          unitPrice: i.product.price,
          quantity: i.quantity,
          imageUrl: i.product.imageUrls.isNotEmpty ? i.product.imageUrls.first : null,
        )).toList(),
        totalAmount: cart.subtotal,
        shippingAddress: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
      );

      cart.clear();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.orderConfirmation,
          arguments: order.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              Text('Order Summary',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...cart.items.map((i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${i.product.title} x${i.quantity}',
                        overflow: TextOverflow.ellipsis)),
                    Text('₱${i.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('₱${cart.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 24),
              // Shipping address
              Text('Shipping Address',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Street, City, Province, ZIP',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Shipping address is required.' : null,
              ),
              const SizedBox(height: 24),
              // Payment method
              Text('Payment Method',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...['GCash', 'PayPal'].map((method) => RadioListTile<String>(
                title: Text(method),
                value: method,
                groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v!),
                contentPadding: EdgeInsets.zero,
              )),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
