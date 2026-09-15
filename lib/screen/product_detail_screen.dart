import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  void _addToCart(BuildContext context) {
    context.read<CartProvider>().add(product);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = products
        .where((item) => item != product && item.category == product.category)
        .toList();
    final suggestedProducts = suggestions.isEmpty
        ? products.where((item) => item != product).take(3).toList()
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
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating.toStringAsFixed(1)} / 5',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Text('${product.comments.length} reviews'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
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
