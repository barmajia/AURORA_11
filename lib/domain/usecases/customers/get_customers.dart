import 'package:aurora/domain/entities/customer.dart';
import 'package:aurora/domain/repositories/customer_repository.dart';

class GetCustomers {
  final CustomerRepository repository;
  GetCustomers(this.repository);

  Future<List<Customer>> call(String sellerId) async {
    return repository.fetchCustomers(sellerId);
  }
}
