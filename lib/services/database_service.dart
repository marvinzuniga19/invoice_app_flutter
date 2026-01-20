import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/company.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';

class DatabaseService {
  static const String invoicesBox = 'invoices';
  static const String customersBox = 'customers';
  static const String companyBox = 'company';
  static const String productsBox = 'products';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(InvoiceItemAdapter());
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(CompanyAdapter());
    Hive.registerAdapter(InvoiceAdapter());
    Hive.registerAdapter(ProductAdapter());

    // Open boxes
    await Hive.openBox<Invoice>(invoicesBox);
    await Hive.openBox<Customer>(customersBox);
    await Hive.openBox<Company>(companyBox);
    await Hive.openBox<Product>(productsBox);
  }

  // Invoice operations
  static Box<Invoice> get invoicesBoxInstance => Hive.box<Invoice>(invoicesBox);

  static Future<void> saveInvoice(Invoice invoice) async {
    await invoicesBoxInstance.put(invoice.id, invoice);
  }

  static Future<void> deleteInvoice(String id) async {
    await invoicesBoxInstance.delete(id);
  }

  static Invoice? getInvoice(String id) {
    return invoicesBoxInstance.get(id);
  }

  static List<Invoice> getAllInvoices() {
    return invoicesBoxInstance.values.toList();
  }

  // Customer operations
  static Box<Customer> get customersBoxInstance =>
      Hive.box<Customer>(customersBox);

  static Future<void> saveCustomer(Customer customer) async {
    await customersBoxInstance.put(customer.id, customer);
  }

  static Future<void> deleteCustomer(String id) async {
    await customersBoxInstance.delete(id);
  }

  static Customer? getCustomer(String id) {
    return customersBoxInstance.get(id);
  }

  static List<Customer> getAllCustomers() {
    return customersBoxInstance.values.toList();
  }

  // Company operations
  static Box<Company> get companyBoxInstance => Hive.box<Company>(companyBox);

  static Future<void> saveCompany(Company company) async {
    await companyBoxInstance.put('company', company);
  }

  static Company getCompany() {
    return companyBoxInstance.get('company') ?? Company();
  }

  // Product operations
  static Box<Product> get productsBoxInstance => Hive.box<Product>(productsBox);

  static Future<void> saveProduct(Product product) async {
    await productsBoxInstance.put(product.id, product);
  }

  static Future<void> deleteProduct(String id) async {
    await productsBoxInstance.delete(id);
  }

  static Product? getProduct(String id) {
    return productsBoxInstance.get(id);
  }

  static List<Product> getAllProducts() {
    return productsBoxInstance.values.toList();
  }
}
