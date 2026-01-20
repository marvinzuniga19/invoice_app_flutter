import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 4)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? sku;

  @HiveField(3)
  double price;

  @HiveField(4)
  double stockQuantity;

  @HiveField(5)
  String? description;

  @HiveField(6)
  double taxPercentage;

  @HiveField(7)
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    this.sku,
    required this.price,
    this.stockQuantity = 0,
    this.description,
    this.taxPercentage = 0,
    this.imagePath,
  });
}
