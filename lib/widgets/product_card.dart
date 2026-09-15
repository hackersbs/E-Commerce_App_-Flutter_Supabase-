import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screen/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 52,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.read<CartProvider>().add(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
