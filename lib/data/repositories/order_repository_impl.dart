import 'package:aurora/domain/entities/order.dart';
import 'package:aurora/domain/repositories/order_repository.dart';
import 'package:aurora/data/sources/remote/order_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderService remoteSource;
  OrderRepositoryImpl(this.remoteSource);

  @override
  Future<List<Order>> fetchOrdersBySeller(String sellerId) => remoteSource.fetchOrdersBySeller(sellerId);

  @override
  Future<List<Order>> fetchOrdersByCustomer(String customerId) => remoteSource.fetchOrdersByCustomer(customerId);

  @override
  Future<Order?> fetchOrderById(String orderId) => remoteSource.fetchOrderById(orderId);

  @override
  Future<Order?> createOrder(Order order) => remoteSource.createOrder(order);

  @override
  Future<Order?> updateOrder(Order order) => remoteSource.updateOrder(order);

  @override
  Future<void> deleteOrder(String orderId) => remoteSource.updateOrderStatus(orderId, 'cancelled');

  @override
  Future<Map<String, dynamic>> getDashboardStats(String sellerId) => remoteSource.getDashboardStats(sellerId);
}
