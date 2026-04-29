import 'package:aurora/data/models/analysis/enums.dart';

class Product {
  final String id; final String sellerId; final String name; final String? description;
  final String? asin; final String? sku; final String? brand; final String? category;
  final String? imageUrl; final List<String>? imageUrls; final double price; final double? compareAtPrice;
  final int stockQuantity; final bool isActive; final bool isInStock; final ProductStatus status;
  final DateTime createdAt; final DateTime updatedAt;

  Product({required this.id, required this.sellerId, required this.name, this.description, this.asin, this.sku,
    this.brand, this.category, this.imageUrl, this.imageUrls, required this.price, this.compareAtPrice,
    this.stockQuantity = 0, this.isActive = true, this.isInStock = true, this.status = ProductStatus.active,
    DateTime? createdAt, DateTime? updatedAt})
    : createdAt = createdAt ?? DateTime.now(), updatedAt = updatedAt ?? DateTime.now();

  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;
  double get discountPercentage {
    if (!hasDiscount || compareAtPrice! == 0) return 0;
    return ((compareAtPrice! - price) / compareAtPrice!) * 100;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String? ?? '', sellerId: map['seller_id'] as String? ?? '', name: map['name'] as String? ?? '',
      description: map['description'] as String?, asin: map['asin'] as String?, sku: map['sku'] as String?,
      brand: map['brand'] as String?, category: map['category'] as String?, imageUrl: map['image_url'] as String?,
      imageUrls: map['image_urls'] is List ? (map['image_urls'] as List).map((e) => e.toString()).toList() : null,
      price: _parseNumeric(map['price']),
      compareAtPrice: map['compare_at_price'] != null ? _parseNumeric(map['compare_at_price']) : null,
      stockQuantity: map['stock_quantity'] as int? ?? 0, isActive: map['is_active'] as bool? ?? true,
      isInStock: map['is_in_stock'] as bool? ?? true,
      status: ProductStatusExtension.fromString(map['status'] as String? ?? 'active'),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'seller_id': sellerId, 'name': name, 'description': description, 'asin': asin, 'sku': sku,
      'brand': brand, 'category': category, 'image_url': imageUrl, 'image_urls': imageUrls, 'price': price,
      'compare_at_price': compareAtPrice, 'stock_quantity': stockQuantity, 'is_active': isActive,
      'is_in_stock': isInStock, 'status': status.value, 'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String()};
  }

  Product copyWith({String? id, String? sellerId, String? name, String? description, String? asin, String? sku,
    String? brand, String? category, String? imageUrl, List<String>? imageUrls, double? price,
    double? compareAtPrice, int? stockQuantity, bool? isActive, bool? isInStock, ProductStatus? status,
    DateTime? createdAt, DateTime? updatedAt}) {
    return Product(id: id ?? this.id, sellerId: sellerId ?? this.sellerId, name: name ?? this.name,
      description: description ?? this.description, asin: asin ?? this.asin, sku: sku ?? this.sku,
      brand: brand ?? this.brand, category: category ?? this.category, imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls, price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice, stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive, isInStock: isInStock ?? this.isInStock, status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt);
  }

  static double _parseNumeric(dynamic value) {
    if (value == null) return 0; if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0; return 0;
  }
}

enum ProductStatus { active, draft, archived, outOfStock }

extension ProductStatusExtension on ProductStatus {
  String get value {
    switch (this) {
      case ProductStatus.active: return 'active';
      case ProductStatus.draft: return 'draft';
      case ProductStatus.archived: return 'archived';
      case ProductStatus.outOfStock: return 'out_of_stock';
    }
  }
  static ProductStatus fromString(String value) {
    switch (value) {
      case 'active': return ProductStatus.active;
      case 'draft': return ProductStatus.draft;
      case 'archived': return ProductStatus.archived;
      case 'out_of_stock': return ProductStatus.outOfStock;
      default: return ProductStatus.active;
    }
  }
}
