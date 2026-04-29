import 'package:aurora/models/customers/customermodel.dart';
import 'package:aurora/storage/customer_storage.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  Future<List<Customer>> fetchCustomers(String sellerId) async {
    return await CustomerStorage.getCustomers();
  }

  Future<Customer?> fetchCustomerById(String customerId) async {
    return await CustomerStorage.getCustomerById(customerId);
  }

  Future<Customer?> createCustomer(Customer customer) async {
    await CustomerStorage.addCustomer(customer);
    return customer;
  }

  Future<Customer?> updateCustomer(Customer customer) async {
    await CustomerStorage.updateCustomer(customer);
    return customer;
  }

  Future<void> deleteCustomer(String customerId) async {
    await CustomerStorage.deleteCustomer(customerId);
  }

  Future<List<Customer>> searchCustomers(String sellerId, String query) async {
    final customers = await fetchCustomers(sellerId);
    final lowerQuery = query.toLowerCase();
    return customers.where((c) =>
        c.name.toLowerCase().contains(lowerQuery) ||
        c.phone.contains(lowerQuery) ||
        (c.email?.toLowerCase().contains(lowerQuery) ?? false)).toList();
  }
}