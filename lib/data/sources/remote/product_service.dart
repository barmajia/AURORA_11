import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aurora/data/models/products/product.dart';
import 'package:aurora/data/sources/local/product_storage.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  Future<List<Product>> fetchProductsBySeller(String sellerId) async {
    try {
      final response = await Supabase.instance.client.from('products').select().eq('seller_id', sellerId).order('created_at', ascending: false);
      final products = response.map((item) => Product.fromMap(item as Map<String, dynamic>)).toList();
      await ProductStorage.saveProducts(products);
      return products;
    } catch (e) { return await ProductStorage.getProductsBySeller(sellerId); }
  }

  Future<Product?> fetchProductById(String productId) async {
    try {
      final response = await Supabase.instance.client.from('products').select().eq('id', productId).maybeSingle();
      if (response != null) return Product.fromMap(response);
    } catch (e) {}
    return await ProductStorage.getProductById(productId);
  }

  Future<Product?> createProduct(Product product) async {
    try {
      final response = await Supabase.instance.client.from('products').insert(product.toMap()).select().maybeSingle();
      if (response != null) { final newProduct = Product.fromMap(response); await ProductStorage.addProduct(newProduct); return newProduct; }
    } catch (e) { await ProductStorage.addProduct(product); }
    return product;
  }

  Future<Product?> updateProduct(Product product) async {
    try {
      final response = await Supabase.instance.client.from('products').update(product.toMap()).eq('id', product.id).select().maybeSingle();
      if (response != null) { final updated = Product.fromMap(response); await ProductStorage.updateProduct(updated); return updated; }
    } catch (e) { await ProductStorage.updateProduct(product); }
    return product;
  }

  Future<void> deleteProduct(String productId) async {
    try { await Supabase.instance.client.from('products').delete().eq('id', productId); } catch (e) {}
    await ProductStorage.deleteProduct(productId);
  }

  Future<List<Product>> searchProducts(String sellerId, String query) async {
    try {
      final response = await Supabase.instance.client.from('products').select().eq('seller_id', sellerId).or('name.ilike.%$query%,description.ilike.%$query%,brand.ilike.%$query%').order('created_at', ascending: false);
      final products = response.map((item) => Product.fromMap(item as Map<String, dynamic>)).toList();
      await ProductStorage.saveProducts(products);
      return products;
    } catch (e) { return await ProductStorage.searchProducts(sellerId, query); }
  }

  Future<List<Product>> getActiveProducts(String sellerId) async {
    final products = await fetchProductsBySeller(sellerId);
    return products.where((p) => p.isActive).toList();
  }

  Future<List<Product>> getOutOfStockProducts(String sellerId) async {
    final products = await fetchProductsBySeller(sellerId);
    return products.where((p) => !p.isInStock).toList();
  }

  Future<Map<String, dynamic>> getInventoryStats(String sellerId) async {
    final products = await fetchProductsBySeller(sellerId);
    int totalProducts = products.length; int activeProducts = 0; int outOfStock = 0; int lowStock = 0; double totalValue = 0;
    for (final product in products) {
      if (product.isActive) activeProducts++;
      if (!product.isInStock) outOfStock++;
      if (product.stockQuantity > 0 && product.stockQuantity <= 10) lowStock++;
      totalValue += product.price * product.stockQuantity;
    }
    return {'total_products': totalProducts, 'active_products': activeProducts, 'out_of_stock': outOfStock, 'low_stock': lowStock, 'total_inventory_value': totalValue};
  }
}
