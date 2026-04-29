import 'dart:convert';
import 'package:vault_storage/vault_storage.dart';
import 'package:aurora/data/models/products/product.dart';

class ProductStorage {
  static late final IVaultStorage _vault;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    final storage = VaultStorage.create();
    await storage.init();
    _vault = storage;
    _isInitialized = true;
  }

  static const String _productsKey = 'products_list';

  static Future<void> _saveString(String key, String value) async {
    await _vault.saveNormal(key: key, value: value);
  }

  static Future<String?> _getString(String key) async {
    return await _vault.get<String>(key);
  }

  static Future<void> saveProducts(List<Product> products) async {
    final jsonList = products.map((p) => p.toMap()).toList();
    await _saveString(_productsKey, jsonEncode(jsonList));
  }

  static Future<List<Product>> getProducts() async {
    final value = await _getString(_productsKey);
    if (value == null || value.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(value);
      return jsonList.map((item) => Product.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) { return []; }
  }

  static Future<List<Product>> getProductsBySeller(String sellerId) async {
    final products = await getProducts();
    return products.where((p) => p.sellerId == sellerId).toList();
  }

  static Future<Product?> getProductById(String productId) async {
    final products = await getProducts();
    try { return products.firstWhere((p) => p.id == productId); } catch (e) { return null; }
  }

  static Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.insert(0, product);
    await saveProducts(products);
  }

  static Future<void> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) { products[index] = product; await saveProducts(products); }
  }

  static Future<void> deleteProduct(String productId) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == productId);
    await saveProducts(products);
  }

  static Future<void> clearProducts() async {
    await _vault.delete(_productsKey);
  }

  static Future<List<Product>> searchProducts(String sellerId, String query) async {
    final products = await getProductsBySeller(sellerId);
    final lowerQuery = query.toLowerCase();
    return products.where((p) =>
        p.name.toLowerCase().contains(lowerQuery) ||
        (p.description?.toLowerCase().contains(lowerQuery) ?? false) ||
        (p.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
        (p.sku?.toLowerCase().contains(lowerQuery) ?? false) ||
        (p.asin?.toLowerCase().contains(lowerQuery) ?? false)).toList();
  }
}
