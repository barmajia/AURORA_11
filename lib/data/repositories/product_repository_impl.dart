import 'package:aurora/domain/entities/product.dart';
import 'package:aurora/domain/repositories/product_repository.dart';
import 'package:aurora/data/sources/remote/product_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductService remoteSource;
  ProductRepositoryImpl(this.remoteSource);

  @override
  Future<List<Product>> fetchProductsBySeller(String sellerId) => remoteSource.fetchProductsBySeller(sellerId);

  @override
  Future<Product?> fetchProductById(String productId) => remoteSource.fetchProductById(productId);

  @override
  Future<Product?> createProduct(Product product) => remoteSource.createProduct(product);

  @override
  Future<Product?> updateProduct(Product product) => remoteSource.updateProduct(product);

  @override
  Future<void> deleteProduct(String productId) => remoteSource.deleteProduct(productId);

  @override
  Future<List<Product>> searchProducts(String sellerId, String query) => remoteSource.searchProducts(sellerId, query);

  @override
  Future<Map<String, dynamic>> getInventoryStats(String sellerId) => remoteSource.getInventoryStats(sellerId);
}
