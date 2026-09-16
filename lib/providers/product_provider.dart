import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Product> _products = const [];
  String? _lastError;

  List<Product> get items => List.unmodifiable(_products);
  String? get lastError => _lastError;

  List<Product> productsForSeller(String sellerId) => _products
      .where((product) => product.sellerId == sellerId)
      .toList(growable: false);

  Future<void> loadProducts() async {
    _lastError = null;
    notifyListeners();
    try {
      final rows = await _supabase
          .from('products')
          .select('*, seller:profiles!products_seller_id_fkey(username)');
      final reviews = await _supabase
          .from('product_reviews')
          .select('product_id, stars, comment');
      final reviewsByProduct = <String, List<String>>{};
      for (final review in reviews as List) {
        final row = Map<String, dynamic>.from(review as Map);
        final id = row['product_id'] as String;
        final text = (row['comment'] as String?) ?? '';
        reviewsByProduct
            .putIfAbsent(id, () => [])
            .add(text.isEmpty ? '${row['stars']}/5 stars' : text);
      }
      _products = (rows as List)
          .map(
            (row) => Product.fromMap(
              Map<String, dynamic>.from(row as Map),
              comments: reviewsByProduct[row['id'] as String] ?? const [],
            ),
          )
          .toList();
    } on PostgrestException catch (error) {
      _lastError = error.message;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product, String sellerId) async {
    _lastError = null;
    try {
      await _supabase.from('products').insert(product.toInsertMap(sellerId));
      await loadProducts();
      return true;
    } on PostgrestException catch (error) {
      _lastError = error.message;
      return false;
    }
  }

  Future<bool> updateProduct(
    String sellerId,
    Product existing,
    Product product,
  ) async {
    if (existing.sellerId != sellerId) return false;
    _lastError = null;
    try {
      await _supabase
          .from('products')
          .update(product.toInsertMap(sellerId))
          .eq('id', existing.id)
          .eq('seller_id', sellerId);
      await loadProducts();
      return true;
    } on PostgrestException catch (error) {
      _lastError = error.message;
      return false;
    }
  }

  Future<bool> deleteProduct(String sellerId, Product product) async {
    if (product.sellerId != sellerId) return false;
    _lastError = null;
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', product.id)
          .eq('seller_id', sellerId);
      await loadProducts();
      return true;
    } on PostgrestException catch (error) {
      _lastError = error.message;
      return false;
    }
  }

  bool hasStock(Product product) => product.stock > 0;

  Future<bool> addReview(Product product, String buyerId, int stars) async {
    if (stars < 1 || stars > 5) return false;
    _lastError = null;
    try {
      await _supabase.from('product_reviews').upsert({
        'product_id': product.id,
        'buyer_id': buyerId,
        'stars': stars,
        'comment': '$stars/5 stars',
      }, onConflict: 'product_id,buyer_id');
      await loadProducts();
      return true;
    } on PostgrestException catch (error) {
      _lastError = error.message;
      return false;
    }
  }
}
