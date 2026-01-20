import 'package:uuid/uuid.dart';
import '../models/product.dart';
import 'database_service.dart';

class InventoryService {
  static const _uuid = Uuid();

  // Create new product
  static Future<Product> createProduct({
    required String name,
    required double price,
    String? sku,
    double stockQuantity = 0,
    String? description,
    double taxPercentage = 0,
    String? imagePath,
  }) async {
    final product = Product(
      id: _uuid.v4(),
      name: name,
      price: price,
      sku: sku,
      stockQuantity: stockQuantity,
      description: description,
      taxPercentage: taxPercentage,
      imagePath: imagePath,
    );

    await DatabaseService.saveProduct(product);
    return product;
  }

  // Update product
  static Future<void> updateProduct(Product product) async {
    await DatabaseService.saveProduct(product);
  }

  // Delete product
  static Future<void> deleteProduct(String id) async {
    await DatabaseService.deleteProduct(id);
  }

  // Get all products
  static List<Product> getAllProducts() {
    return DatabaseService.getAllProducts();
  }

  // Search products
  static List<Product> searchProducts(String query) {
    final products = getAllProducts();
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          (product.sku?.toLowerCase().contains(lowerQuery) ?? false) ||
          (product.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
