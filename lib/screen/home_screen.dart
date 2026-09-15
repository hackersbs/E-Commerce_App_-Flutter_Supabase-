import 'package:flutter/material.dart';

import '../widgets/product_card.dart';
import '../widgets/bottom_navigation.dart';
import '../models/product.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Products'), elevation: 0),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    // Show the grid only on the "Home" tab
    if (_selectedIndex == 0) {
      final searchResults = products
          .where(
            (product) =>
                product.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.60,
                          ),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: searchResults[index]);
                      },
                    ),
                  ),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      // Profile tab
      return const ProfileScreen();
    } else if (_selectedIndex == 2) {
      // Cart tab
      return const CartScreen();
    } else if (_selectedIndex == 3) {
      // Settings tab
      return const SettingsScreen();
    }

    // Fallback
    return const SizedBox.shrink();
  }
}
