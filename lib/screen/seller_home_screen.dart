import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import 'auth_screen.dart';
import '../utils/currency.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  Future<void> _openProductForm(BuildContext context, {int? index}) async {
    final productProvider = context.read<ProductProvider>();
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final sellerProducts = productProvider.productsForSeller(user.id);
    final product = index == null ? null : sellerProducts[index];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductForm(
        product: product,
        index: index,
        sellerId: user.id,
        sellerName: user.username,
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, int index) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final sellerProducts = context.read<ProductProvider>().productsForSeller(
      user.id,
    );
    final product = sellerProducts[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove ${product.name} from the store?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProductProvider>().deleteProduct(user.id, product);
    }
  }

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final username = user?.username ?? '';
    final products = context.watch<ProductProvider>().productsForSeller(
      user?.id ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: products.isEmpty
          ? const Center(
              child: Text('No products yet. Add your first product.'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Text(
                  'Welcome, $username',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('${products.length} products in your store'),
                const SizedBox(height: 16),
                ...List.generate(
                  products.length,
                  (index) => SellerProductTile(
                    product: products[index],
                    onEdit: () => _openProductForm(context, index: index),
                    onDelete: () => _deleteProduct(context, index),
                  ),
                ),
              ],
            ),
    );
  }
}

class SellerProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SellerProductTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stackTrace) =>
                      const Icon(Icons.image_not_supported_outlined, size: 36),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.category}  •  ${formatInr(product.price)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Quantity available: ${product.stock}'),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: [
                IconButton(
                  tooltip: 'Edit product',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  tooltip: 'Delete product',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductForm extends StatefulWidget {
  final Product? product;
  final int? index;
  final String sellerId;
  final String sellerName;

  const ProductForm({
    super.key,
    this.product,
    this.index,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(2),
    );
    _imageController = TextEditingController(text: product?.imageUrl ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _stockController = TextEditingController(
      text: product == null ? '1' : product.stock.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Enter $label' : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final currentProduct = widget.product;
    final product = Product(
      id: currentProduct?.id ?? '',
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imageUrl: _imageController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      rating: currentProduct?.rating ?? 0,
      ratingCount: currentProduct?.ratingCount ?? 0,
      comments: currentProduct?.comments ?? const [],
      stock: int.parse(_stockController.text.trim()),
      sellerId: currentProduct?.sellerId ?? widget.sellerId,
      sellerName: currentProduct?.sellerName ?? widget.sellerName,
    );
    final provider = context.read<ProductProvider>();
    late final bool saved;
    if (widget.index == null) {
      saved = await provider.addProduct(product, widget.sellerId);
    } else {
      saved = await provider.updateProduct(
        widget.sellerId,
        widget.product!,
        product,
      );
    }
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.lastError ?? 'Could not save product to Supabase',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.index != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit product' : 'Add product',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (value) => _required(value, 'a product name'),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (_required(value, 'a price') != null ||
                      double.tryParse(value!.trim()) == null) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => _required(value, 'a category'),
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) => _required(value, 'an image URL'),
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => _required(value, 'a description'),
              ),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Product quantity',
                  helperText: 'Number of units available for buyers',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  final stock = int.tryParse(value?.trim() ?? '');
                  return stock == null || stock < 0
                      ? 'Enter a valid stock quantity'
                      : null;
                },
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(isEditing ? 'Save changes' : 'Add product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
