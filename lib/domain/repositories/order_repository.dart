import 'package:aurora/domain/entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> fetchOrdersBySeller(String sellerId);
  Future<List<Order>> fetchOrdersByCustomer(String customerId);
  Future<Order?> fetchOrderById(String orderId);
  Future<Order?> createOrder(Order order);
  Future<Order?> updateOrder(Order order);
  Future<void> deleteOrder(String orderId);
  Future<Map<String, dynamic>> getDashboardStats(String sellerId);
}
