import 'package:aurora/domain/entities/product.dart';
import 'package:aurora/domain/repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;
  GetProducts(this.repository);

  Future<List<Product>> call(String sellerId) async {
    return repository.fetchProductsBySeller(sellerId);
  }
}
