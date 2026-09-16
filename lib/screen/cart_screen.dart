import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../utils/currency.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.uniqueItems;

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
                subtitle: Text(
                  '${formatInr(product.price)}  •  Quantity: ${cart.quantityFor(product)}',
                ),
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Decrease quantity',
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () async {
                        await cart.remove(product);
                      },
                    ),
                    Text('${cart.quantityFor(product)}'),
                    IconButton(
                      tooltip: 'Increase quantity',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () async {
                        final added = await cart.add(product);
                        if (!context.mounted || added) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              cart.lastError ?? 'Product is out of stock',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 380;
              final total = Text(
                'Total: ${formatInr(cart.totalPrice)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
              final buyButton = ElevatedButton.icon(
                onPressed: () async {
                  final totalPrice = cart.totalPrice;
                  final orderId = await cart.checkout();
                  if (!context.mounted || orderId == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Purchase placed for ${formatInr(totalPrice)}',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Buy all'),
              );
              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [total, buyButton],
                    )
                  : Row(
                      children: [
                        Expanded(child: total),
                        buyButton,
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }
}
