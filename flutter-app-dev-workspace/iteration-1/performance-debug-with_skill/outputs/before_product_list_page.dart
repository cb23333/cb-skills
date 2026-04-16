/// BEFORE: Performance-problematic product list page
///
/// This file demonstrates common performance mistakes in Flutter list pages.
/// DO NOT use this code in production - see the "after" version for fixes.

import 'package:flutter/material.dart';

// -------------------------------------------------------
// Mock product model (for demonstration purposes)
// -------------------------------------------------------
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

// -------------------------------------------------------
// Mock data source
// -------------------------------------------------------
List<Product> fetchProducts() {
  return List.generate(
    2000,
    (index) => Product(
      id: '$index',
      name: 'Product #$index',
      price: (index + 1) * 9.99,
      imageUrl: 'https://example.com/images/product_$index.png',
      description: 'This is a detailed description for product #$index. '
          'It contains multiple lines of text to simulate a real-world '
          'product description that would be displayed in the list item.',
    ),
  );
}

// -------------------------------------------------------
// PROBLEM: ProductListPage with multiple performance issues
// -------------------------------------------------------
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late List<Product> _products;

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Column(
        children: [
          // Search bar (rebuilds entire list on every keystroke)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  // ISSUE 4: Filtering triggers full rebuild
                  _products = fetchProducts()
                      .where((p) => p.name.contains(value))
                      .toList();
                });
              },
            ),
          ),
          // ISSUE 1: Using ListView with children instead of ListView.builder
          // This loads ALL items into memory at once
          Expanded(
            child: ListView(
              children: _products.map((product) {
                // ISSUE 2: No const constructors, every item rebuilds
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // ISSUE 3: Images loaded without caching or thumbnails
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            // No caching strategy, no placeholder, no error handling
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.description,
                                // ISSUE 5: Full description shown in list item
                                // Heavy text layout for every item
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ISSUE 6: Each item has its own Material widget
                        // causing unnecessary repaint layers
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate to detail
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
