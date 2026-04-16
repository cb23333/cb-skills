// features/product/presentation/product_list_screen.dart
// AFTER: Performance-optimized version
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
  // FIX 1: Use ValueNotifier for FAB visibility instead of setState on scroll
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showScrollToTop.dispose();
    super.dispose();
  }

  void _onScroll() {
    // FIX 1: Only update ValueNotifier, not full setState
    final shouldShow = _scrollController.offset > 200;
    if (_showScrollToTop.value != shouldShow) {
      _showScrollToTop.value = shouldShow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
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
            // FIX 2: Use ListView.builder for lazy rendering
            // Only visible items are built, dramatically reducing memory and CPU usage
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              // FIX 3: Use itemExtent or prototypeItem for better performance
              // (commented out since items have variable height due to descriptions)
              // itemExtent: 280,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  // FIX 4: Use separate widget class to enable const optimization
                  child: ProductListItem(
                    product: products[index],
                    onTap: () => _navigateToDetail(context, products[index].id),
                    onAddToCart: () => _addToCart(context, products[index]),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(productListProvider),
        ),
      ),
      // FIX 1: Use ValueListenableBuilder for FAB, avoids full rebuild on scroll
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showScrollToTop,
        builder: (context, show, _) {
          return AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton(
              onPressed: show
                  ? () {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              child: const Icon(Icons.arrow_upward),
            ),
          );
        },
      ),
    );
  }

  // FIX 5: Extract navigation logic to avoid closures in build
  void _navigateToDetail(BuildContext context, String productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productId: productId),
      ),
    );
  }

  // FIX 5: Extract cart logic to avoid closures in build
  void _addToCart(BuildContext context, ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${product.name} to cart')),
    );
  }
}

// FIX 4: Extract item as a separate StatelessWidget for better rebuild control
// Flutter can skip rebuilding this widget if the product data hasn't changed
class ProductListItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // FIX 6: Wrap in RepaintBoundary so this item doesn't trigger repaint of others
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
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
              // FIX 7: Use cached_network_image or at least proper error handling
              _ProductImage(imageUrl: product.imageUrl),
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
                  _StockBadge(isInStock: product.isInStock),
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
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.add_shopping_cart),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FIX 7: Separate image widget with proper placeholder, error, and fade-in
class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // FIX 7: Handle null/empty imageUrl gracefully
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_not_supported, size: 48),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        // FIX 7: Add fade-in animation for smoother UX
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
        // FIX 7: Proper error widget instead of broken image
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.broken_image, size: 48),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

// FIX 8: Extract stock badge as const-optimizable widget
class _StockBadge extends StatelessWidget {
  final bool isInStock;

  const _StockBadge({required this.isInStock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isInStock
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isInStock ? 'In Stock' : 'Out of Stock',
        style: TextStyle(
          fontSize: 12,
          color: isInStock ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

// FIX 9: Extract error view as reusable widget
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
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
