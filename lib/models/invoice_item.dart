import 'package:hive/hive.dart';

part 'invoice_item.g.dart';

@HiveType(typeId: 0)
class InvoiceItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  double unitPrice;

  @HiveField(4)
  double taxPercentage;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.taxPercentage = 0.0,
  });

  double get subtotal => quantity * unitPrice;

  double get taxAmount => subtotal * (taxPercentage / 100);

  double get total => subtotal + taxAmount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'taxPercentage': taxPercentage,
  };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    id: json['id'],
    description: json['description'],
    quantity: json['quantity'],
    unitPrice: json['unitPrice'],
    taxPercentage: json['taxPercentage'] ?? 0.0,
  );
}
