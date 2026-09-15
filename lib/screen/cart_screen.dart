import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;

    if (cartItems.isEmpty) {
      return const Center(
        child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final product = cartItems[index];
              return ListTile(
                leading: Image.network(
                  product.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported_outlined, size: 40),
                ),
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    cart.removeAt(index);
                  },
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total: \$${cart.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final total = cart.totalPrice;
                  cart.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Purchase placed for \$${total.toStringAsFixed(2)}',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Buy all'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
