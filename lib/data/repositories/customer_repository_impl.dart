import 'package:aurora/domain/entities/customer.dart';
import 'package:aurora/domain/repositories/customer_repository.dart';
import 'package:aurora/data/sources/remote/customer_service.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerService remoteSource;
  CustomerRepositoryImpl(this.remoteSource);

  @override
  Future<List<Customer>> fetchCustomers(String sellerId) => remoteSource.fetchCustomers(sellerId);

  @override
  Future<Customer?> fetchCustomerById(String customerId) => remoteSource.fetchCustomerById(customerId);

  @override
  Future<Customer?> createCustomer(Customer customer) => remoteSource.createCustomer(customer);

  @override
  Future<Customer?> updateCustomer(Customer customer) => remoteSource.updateCustomer(customer);

  @override
  Future<void> deleteCustomer(String customerId) => remoteSource.deleteCustomer(customerId);

  @override
  Future<List<Customer>> searchCustomers(String sellerId, String query) => remoteSource.searchCustomers(sellerId, query);
}
