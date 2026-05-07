import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class WriteReviewScreen extends StatefulWidget {
  final String productId;
  final String orderId;

  const WriteReviewScreen({
    super.key,
    required this.productId,
    required this.orderId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a rating.')));
      return;
    }
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write your feedback.')));
      return;
    }

    setState(() => _isSubmitting = true);

    final user = context.read<AuthProvider>().currentUser!;
    final review = ReviewModel(
      id: '', // Will be assigned by Firestore
      productId: widget.productId,
      orderId: widget.orderId,
      buyerId: user.uid,
      buyerDisplayName: user.displayName,
      rating: _rating,
      feedback: _feedbackController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await context.read<ProductProvider>().addReview(review);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted. Thank you!')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = context.read<ProductProvider>().getById(widget.productId);

    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product != null) ...[
              Text(product.title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
            ],
            const Text('Your Rating'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) => IconButton(
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
                onPressed: () => setState(() => _rating = i + 1),
              )),
            ),
            const SizedBox(height: 16),
            const Text('Your Feedback'),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share your experience with this product...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
