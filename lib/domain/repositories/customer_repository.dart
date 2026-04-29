import 'package:aurora/domain/entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> fetchCustomers(String sellerId);
  Future<Customer?> fetchCustomerById(String customerId);
  Future<Customer?> createCustomer(Customer customer);
  Future<Customer?> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String customerId);
  Future<List<Customer>> searchCustomers(String sellerId, String query);
}
