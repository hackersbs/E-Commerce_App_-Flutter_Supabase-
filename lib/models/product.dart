class Product {
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String category;
  final double rating;
  final List<String> comments;

  Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.rating,
    required this.comments,
  });
}

final List<Product> products = [
  Product(
    name: 'Running Sneakers',
    price: 59.99,
    imageUrl: 'https://picsum.photos/seed/sneakers/600/600',
    description: 'Lightweight sneakers with cushioned support for everyday runs and walks.',
    category: 'Footwear',
    rating: 4.8,
    comments: ['Very comfortable for long walks.', 'The fit is true to size.'],
  ),
  Product(
    name: 'Casual Backpack',
    price: 39.99,
    imageUrl: 'https://picsum.photos/seed/backpack/600/600',
    description: 'A durable everyday backpack with room for your laptop, books, and essentials.',
    category: 'Bags',
    rating: 4.6,
    comments: [
      'The pockets are really useful.',
      'Looks great and feels sturdy.',
    ],
  ),
  Product(
    name: 'Smart Watch',
    price: 199.99,
    imageUrl: 'https://picsum.photos/seed/watch/600/600',
    description: 'Track your activity, notifications, and daily goals with a bright smart display.',
    category: 'Electronics',
    rating: 4.7,
    comments: ['The battery lasts several days.', 'Easy to set up and use.'],
  ),
  Product(
    name: 'Sunglasses',
    price: 29.99,
    imageUrl: 'https://picsum.photos/seed/sunglasses/600/600',
    description: 'Classic sunglasses with UV protection and a comfortable lightweight frame.',
    category: 'Accessories',
    rating: 4.4,
    comments: [
      'Great style for the price.',
      'The frame is light and comfortable.',
    ],
  ),
  Product(
    name: 'Wireless Earbuds',
    price: 89.99,
    imageUrl: 'https://picsum.photos/seed/earbuds/600/600',
    description: 'Compact wireless earbuds with clear sound and a pocket-sized charging case.',
    category: 'Electronics',
    rating: 4.5,
    comments: [
      'Sound quality is crisp.',
      'They stay in place while exercising.',
    ],
  ),
  Product(
    name: 'Gaming Mouse',
    price: 49.99,
    imageUrl: 'https://picsum.photos/seed/mouse/600/600',
    description: 'Responsive gaming mouse with adjustable sensitivity and comfortable controls.',
    category: 'Electronics',
    rating: 4.7,
    comments: ['Very responsive for gaming.', 'The buttons feel solid.'],
  ),
];
