import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

part 'customer_provider.g.dart';

@riverpod
class CustomerList extends _$CustomerList {
  @override
  List<Customer> build() {
    return DatabaseService.getAllCustomers();
  }

  Future<void> addCustomer(Customer customer) async {
    await DatabaseService.saveCustomer(customer);
    ref.invalidateSelf();
  }

  Future<void> deleteCustomer(String id) async {
    await DatabaseService.deleteCustomer(id);
    ref.invalidateSelf();
  }

  List<Customer> filter(String query) {
    final customers = state;
    if (query.isEmpty) return customers;
    return customers.where((c) {
      return c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.email.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
