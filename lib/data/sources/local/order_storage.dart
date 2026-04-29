import 'dart:convert';
import 'package:vault_storage/vault_storage.dart';
import 'package:aurora/data/models/customers/customerbill.dart';

class OrderStorage {
  static late final IVaultStorage _vault;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    final storage = VaultStorage.create();
    await storage.init();
    _vault = storage;
    _isInitialized = true;
  }

  static Future<void> _saveString(String key, String value) async {
    await _vault.saveNormal(key: key, value: value);
  }

  static Future<String?> _getString(String key) async {
    return await _vault.get<String>(key);
  }

  static Future<void> saveOrders(List<Order> orders) async {
    final list = orders.map((o) => o.toMap()).toList();
    await _saveString('orders_list', jsonEncode(list));
  }

  static Future<List<Order>> getOrders() async {
    final value = await _getString('orders_list');
    if (value == null || value.isEmpty) return [];
    try {
      final list = jsonDecode(value) as List;
      return list.map((item) => Order.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) { return []; }
  }

  static Future<List<Order>> getOrdersByCustomer(String customerId) async {
    final orders = await getOrders();
    return orders.where((o) => o.userId == customerId).toList();
  }

  static Future<Order?> getOrderById(String id) async {
    final orders = await getOrders();
    try { return orders.firstWhere((o) => o.id == id); } catch (e) { return null; }
  }

  static Future<void> addOrder(Order order) async {
    final orders = await getOrders();
    orders.insert(0, order);
    await saveOrders(orders);
  }

  static Future<void> updateOrder(Order order) async {
    final orders = await getOrders();
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index != -1) { orders[index] = order; await saveOrders(orders); }
  }

  static Future<void> deleteOrder(String id) async {
    final orders = await getOrders();
    orders.removeWhere((o) => o.id == id);
    await saveOrders(orders);
  }

  static Future<void> clearOrders() async {
    await _vault.delete('orders_list');
  }
}
