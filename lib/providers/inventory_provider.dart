import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/product.dart';
import '../services/inventory_service.dart';

part 'inventory_provider.g.dart';

@riverpod
class InventoryList extends _$InventoryList {
  @override
  List<Product> build() {
    return InventoryService.getAllProducts();
  }

  Future<void> createProduct({
    required String name,
    required double price,
    String? sku,
    double stockQuantity = 0,
    String? description,
    double taxPercentage = 0,
    String? imagePath,
  }) async {
    await InventoryService.createProduct(
      name: name,
      price: price,
      sku: sku,
      stockQuantity: stockQuantity,
      description: description,
      taxPercentage: taxPercentage,
      imagePath: imagePath,
    );
    ref.invalidateSelf();
  }

  Future<void> updateProduct(Product product) async {
    await InventoryService.updateProduct(product);
    ref.invalidateSelf();
  }

  Future<void> deleteProduct(String id) async {
    await InventoryService.deleteProduct(id);
    ref.invalidateSelf();
  }

  List<Product> search(String query) {
    if (query.isEmpty) return state;
    return InventoryService.searchProducts(query);
  }
}
