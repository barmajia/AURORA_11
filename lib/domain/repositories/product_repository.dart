import 'package:aurora/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProductsBySeller(String sellerId);
  Future<Product?> fetchProductById(String productId);
  Future<Product?> createProduct(Product product);
  Future<Product?> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
  Future<List<Product>> searchProducts(String sellerId, String query);
  Future<Map<String, dynamic>> getInventoryStats(String sellerId);
}
