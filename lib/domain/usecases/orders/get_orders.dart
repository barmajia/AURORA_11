import 'package:aurora/domain/entities/order.dart';
import 'package:aurora/domain/repositories/order_repository.dart';

class GetOrders {
  final OrderRepository repository;
  GetOrders(this.repository);

  Future<List<Order>> call(String sellerId) async {
    return repository.fetchOrdersBySeller(sellerId);
  }
}
