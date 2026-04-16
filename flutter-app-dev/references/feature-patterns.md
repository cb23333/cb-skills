# Feature Development Patterns

Detailed code patterns for building features in Flutter.

## Table of Contents
1. [Feature Structure](#feature-structure)
2. [Data Layer Patterns](#data-layer-patterns)
3. [Domain Layer Patterns](#domain-layer-patterns)
4. [Presentation Layer Patterns](#presentation-layer-patterns)
5. [Common UI Patterns](#common-ui-patterns)
6. [Testing Patterns](#testing-patterns)

---

## Feature Structure

Each feature follows the same structure:

```
features/[feature_name]/
├── data/
│   ├── [feature]_model.dart        # Data model with freezed
│   ├── [feature]_repository.dart   # Data access (API calls)
│   └── [feature]_provider.dart     # Data-layer providers
├── domain/
│   └── [feature]_state.dart        # Business logic providers
└── presentation/
    ├── [feature]_screen.dart       # Main screen
    └── widgets/                    # Screen-specific widgets
        ├── [widget_name].dart
        └── ...
```

---

## Data Layer Patterns

### Model with Freezed

```dart
// features/product/data/product_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    String? description,
    String? imageUrl,
    @Default(false) bool isInStock,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
```

Notes:
- `@Default(false)` sets a default value when JSON doesn't contain the field
- `@JsonKey(name: 'created_at')` maps snake_case API fields to camelCase
- Run `dart run build_runner build` after creating or modifying

### Repository Pattern

```dart
// features/product/data/product_repository.dart
import 'package:dio/dio.dart';

class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    final response = await _dio.get('/products', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return (response.data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> getProduct(String id) async {
    final response = await _dio.get('/products/$id');
    return ProductModel.fromJson(response.data);
  }

  Future<ProductModel> createProduct({
    required String name,
    required double price,
    String? description,
  }) async {
    final response = await _dio.post('/products', data: {
      'name': name,
      'price': price,
      if (description != null) 'description': description,
    });
    return ProductModel.fromJson(response.data);
  }
}

// Provider for the repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(dioProvider));
});
```

### Repository with Local Cache

```dart
// features/product/data/cached_product_repository.dart
class CachedProductRepository {
  final ProductApi _api;
  final ProductCache _cache;

  Future<List<ProductModel>> getProducts() async {
    try {
      final products = await _api.getProducts();
      await _cache.saveProducts(products);
      return products;
    } on DioException {
      // Fallback to cache on network error
      return _cache.getProducts();
    }
  }
}
```

---

## Domain Layer Patterns

### Simple Async Provider (read-only data)

```dart
// features/product/domain/product_provider.dart
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});

final productDetailProvider = FutureProvider.family<ProductModel, String>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProduct(id);
});
```

### Notifier with Actions (CRUD operations)

```dart
// features/cart/domain/cart_provider.dart
@riverpod
class Cart extends _$Cart {
  @override
  List<CartItem> build() {
    return []; // Start with empty cart
  }

  void addItem(ProductModel product, {int quantity = 1}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      // Update quantity of existing item
      state = [
        ...state.sublist(0, existingIndex),
        state[existingIndex].copyWith(quantity: state[existingIndex].quantity + quantity),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clear() {
    state = [];
  }

  double get totalPrice => state.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
}
```

### Async Notifier (data that comes from API)

```dart
@riverpod
class ProductList extends _$ProductList {
  @override
  Future<List<ProductModel>> build() async {
    final repository = ref.watch(productRepositoryProvider);
    return repository.getProducts();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> createProduct({
    required String name,
    required double price,
  }) async {
    final repository = ref.watch(productRepositoryProvider);
    final newProduct = await repository.createProduct(name: name, price: price);

    // Add to current list without refetching everything
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, newProduct]);
  }
}
```

---

## Presentation Layer Patterns

### List Screen with Pull-to-Refresh

```dart
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: productsAsync.when(
        data: (products) => RefreshIndicator(
          onRefresh: () => ref.read(productListProvider.notifier).refresh(),
          child: products.isEmpty
              ? const EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'No products yet',
                  subtitle: 'Check back later!',
                )
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    onTap: () => context.push('/products/${products[index].id}'),
                  ),
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(productListProvider),
        ),
      ),
    );
  }
}
```

### Form Screen

```dart
class CreateProductScreen extends ConsumerStatefulWidget {
  const CreateProductScreen({super.key});

  @override
  ConsumerState<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(productListProvider.notifier).createProduct(
        name: _nameController.text,
        price: double.parse(_priceController.text),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value?.isEmpty == true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Common UI Patterns

### Reusable Empty State Widget

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

### Reusable Error View

```dart
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

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
```

---

## Testing Patterns

### Unit Testing a Provider

```dart
// test/features/product/domain/product_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepo;

  setUp(() {
    mockRepo = MockProductRepository();
  });

  test('productsProvider returns list of products', () async {
    // Arrange
    final products = [
      ProductModel(id: '1', name: 'Test', price: 9.99),
    ];
    when(() => mockRepo.getProducts()).thenAnswer((_) async => products);

    // Act
    final container = ProviderContainer(overrides: [
      productRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    final result = await container.read(productsProvider.future);

    // Assert
    expect(result, equals(products));
    container.dispose();
  });
}
```

### Widget Testing a Screen

```dart
// test/features/product/presentation/product_list_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows products', (tester) async {
    // Arrange
    final container = ProviderContainer(overrides: [
      productListProvider.overrideWith(() => MockProductListNotifier()),
    ]);

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProductListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Test Product'), findsOneWidget);
    container.dispose();
  });
}
```
