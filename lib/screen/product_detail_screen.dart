import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../utils/currency.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product get product => widget.product;

  Future<void> _addToCart(BuildContext context) async {
    if (!context.read<ProductProvider>().hasStock(product)) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Icon(Icons.error_outline, color: Colors.red, size: 42),
          content: const Text(
            'Product is out of stock',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final cart = context.read<CartProvider>();
    final added = await cart.add(product);
    if (!context.mounted) return;
    if (!added) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Icon(Icons.error_outline, color: Colors.red, size: 42),
          content: Text(
            cart.lastError ?? 'Product is out of stock',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final productProvider = context.read<ProductProvider>();
    await productProvider.loadProducts();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
  }

  Future<void> _showRatingDialog(BuildContext context) async {
    var selectedStars = 5;
    final stars = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rate this product'),
          content: Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            children: List.generate(
              5,
              (index) => SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '${index + 1} stars',
                  onPressed: () =>
                      setDialogState(() => selectedStars = index + 1),
                  icon: Icon(
                    index < selectedStars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, selectedStars),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || stars == null) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final provider = context.read<ProductProvider>();
    final saved = await provider.addReview(product, user.id, stars);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Thanks for your review'
              : provider.lastError ?? 'Could not save your review',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableProducts = context.watch<ProductProvider>().items;
    final product = availableProducts.firstWhere(
      (item) =>
          item.name == widget.product.name &&
          item.imageUrl == widget.product.imageUrl &&
          item.sellerId == widget.product.sellerId,
      orElse: () => widget.product,
    );
    final suggestions = availableProducts
        .where((item) => item != product && item.category == product.category)
        .toList();
    final suggestedProducts = suggestions.isEmpty
        ? availableProducts.where((item) => item != product).take(3).toList()
        : suggestions;

    return Scaffold(
      appBar: AppBar(title: const Text('Product details')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    const Icon(Icons.storefront_outlined, size: 18),
                    Text(
                      'Sold by ${product.sellerName}',
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating.toStringAsFixed(1)} / 5',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text('${product.comments.length} reviews'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Stock available: ${product.stock}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Text(
                  formatInr(product.price),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _addToCart(context),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to cart'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showRatingDialog(context),
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Rate this product'),
                ),
                const SizedBox(height: 28),
                Text(
                  'Customer reviews',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...product.comments.map(
                  (comment) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(comment),
                    subtitle: const Text('Verified customer'),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'You may also like',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 245,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestedProducts.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => SizedBox(
                      width: 165,
                      child: ProductCard(product: suggestedProducts[index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
