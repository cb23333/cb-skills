// features/product/data/product_model.dart
// Data model for products (used by both before/after versions)
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
