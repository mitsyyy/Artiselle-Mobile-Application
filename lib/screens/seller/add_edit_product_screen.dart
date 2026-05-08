import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/store_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;
  const AddEditProductScreen({super.key, this.productId});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _imageCtrl;
  String? _selectedCategoryId;
  bool _isSaving = false;
  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    final existing = _isEditing
        ? context.read<ProductProvider>().getById(widget.productId!)
        : null;
    _titleCtrl = TextEditingController(text: existing?.title ?? '');
    _descCtrl = TextEditingController(text: existing?.description ?? '');
    _priceCtrl = TextEditingController(
        text: existing != null ? existing.price.toString() : '');
    _stockCtrl = TextEditingController(
        text: existing != null ? existing.stock.toString() : '');
    _imageCtrl = TextEditingController(
        text: (existing?.imageUrls.isNotEmpty == true)
            ? existing!.imageUrls.first
            : '');
    _selectedCategoryId = existing?.categoryId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<ProductProvider>();
    final user = context.read<AuthProvider>().currentUser!;
    final store = context.read<StoreProvider>().getStore(user.uid);
    final storeName = store?.storeName ?? user.displayName;
    final price = double.parse(_priceCtrl.text.trim());
    final stock = int.parse(_stockCtrl.text.trim());
    final imageUrl = _imageCtrl.text.trim().isEmpty
        ? 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/400'
        : _imageCtrl.text.trim();

    try {
      if (_isEditing) {
        final existing = provider.getById(widget.productId!)!;
        await provider.updateProduct(existing.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: price,
          categoryId: _selectedCategoryId,
          stock: stock,
          imageUrls: [imageUrl],
        ));
      } else {
        await provider.addProduct(ProductModel(
          id: '', // Will be assigned by Firestore
          sellerId: user.uid,
          sellerStoreName: storeName,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: price,
          categoryId: _selectedCategoryId ?? kStaticCategories.first.id,
          stock: stock,
          imageUrls: [imageUrl],
          createdAt: DateTime.now(),
        ));
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save product. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Title *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description *', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Description is required.'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Price (₱) *',
                          border: OutlineInputBorder()),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null) return 'Enter a valid price.';
                        if (n <= 0) return 'Price must be > 0.';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Stock *',
                          border: OutlineInputBorder()),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null) return 'Enter a valid number.';
                        if (n < 0) return 'Stock cannot be negative.';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                    labelText: 'Category *', border: OutlineInputBorder()),
                items: kStaticCategories
                    .where((c) => c.isActive)
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) =>
                    v == null ? 'Please select a category.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  border: OutlineInputBorder(),
                  helperText: 'Leave blank to use a placeholder image',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isEditing ? 'Save Changes' : 'Publish Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
