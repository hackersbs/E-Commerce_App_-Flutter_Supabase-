class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String category;
  final double rating;
  final int ratingCount;
  final List<String> comments;
  final int stock;
  final String? sellerId;
  final String sellerName;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.rating,
    required this.ratingCount,
    required this.comments,
    required this.stock,
    this.sellerId,
    required this.sellerName,
  });

  factory Product.fromMap(
    Map<String, dynamic> map, {
    List<String> comments = const [],
  }) {
    final seller = map['seller'] as Map<String, dynamic>?;
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
      comments: comments,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      sellerId: map['seller_id'] as String?,
      sellerName: seller?['username'] as String? ?? 'Store seller',
    );
  }

  Map<String, dynamic> toInsertMap(String sellerId) => {
    'seller_id': sellerId,
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'description': description,
    'category': category,
    'stock': stock,
  };
}
