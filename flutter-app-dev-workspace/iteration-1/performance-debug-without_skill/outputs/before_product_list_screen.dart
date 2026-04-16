// features/product/presentation/product_list_screen.dart
// BEFORE: Performance-optimized version (has multiple issues)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_model.dart';
import '../../domain/product_provider.dart';
import 'widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // ISSUE: setState called on every scroll pixel, triggering full rebuild
    setState(() {});
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        // ISSUE: Search in AppBar triggers full body rebuild on every keystroke
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: productsAsync.when(
        data: (products) {
          final filtered = _filterProducts(products);

          if (filtered.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('No products found'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(productListProvider.notifier).refresh(),
            // CRITICAL ISSUE: Using ListView instead of ListView.builder
            // This renders ALL items at once, not just visible ones
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // ISSUE: Filtering creates new list on every rebuild
                ...filtered.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildProductItem(context, product),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(productListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      // ISSUE: FAB visibility check uses setState on scroll - causes full rebuild
      floatingActionButton: _scrollController.hasClients &&
              _scrollController.offset > 200
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  // ISSUE: Heavy item widget built as inline method - no const optimization possible
  // ISSUE: No RepaintBoundary, so one item changing repaints the entire list
  Widget _buildProductItem(BuildContext context, ProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ISSUE: Image loaded without caching and without error handling
            // Each image is loaded fresh, no cached network image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl ?? '',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                // ISSUE: No error widget, no placeholder, no fade-in
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // ISSUE: No const, rebuilt every time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: product.isInStock
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.isInStock ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.isInStock ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            if (product.description != null) ...[
              const SizedBox(height: 4),
              Text(
                product.description!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () {
                    // ISSUE: Inline anonymous function created on every build
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${product.name} to cart')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder - in real app this would be a separate file
class ProductDetailPage extends StatelessWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Center(child: Text('Product: $productId')),
    );
  }
}
