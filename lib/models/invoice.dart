import 'package:hive/hive.dart';
import 'invoice_item.dart';

part 'invoice.g.dart';

@HiveType(typeId: 3)
class Invoice extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String invoiceNumber;

  @HiveField(2)
  DateTime invoiceDate;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(
    4,
  ) // Retain ID to avoid breaking existing Hive data structure if possible, or just ignore.
  // I will deprecate this field or just reuse it? No, Hive uses index.
  // If I remove index 4, future reads might be weird if I don't migrate.
  // Actually, for a clean refactor, I should probably keep the index reservation or handle migration.
  // Since this is likely dev env, I will just replace.
  // Wait, the plan said "Remove customerId".
  // Index 4 was customerId.
  // I will make customerSurname index 11 and customerCompany index 12 as planned to avoid collision.
  // But wait, removing a field from Hive usually you just stop using it.
  // I will remove the field from the class.
  //
  // NOTE: If I remove the field from the class, Hive might ignore it on read.
  @HiveField(5)
  String customerName;

  @HiveField(6)
  List<InvoiceItem> items;

  @HiveField(7)
  double discountPercentage;

  @HiveField(8)
  String notes;

  @HiveField(9)
  bool isPaid;

  @HiveField(10)
  String currency;

  @HiveField(11)
  String customerSurname;

  @HiveField(12)
  String customerCompany;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.customerName,
    this.customerSurname = '',
    this.customerCompany = '',
    required this.items,
    this.discountPercentage = 0.0,
    this.notes = '',
    this.isPaid = false,
    this.currency = 'USD',
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalTax => items.fold(0.0, (sum, item) => sum + item.taxAmount);

  double get totalBeforeDiscount => subtotal + totalTax;

  double get discountAmount => totalBeforeDiscount * (discountPercentage / 100);

  double get total => totalBeforeDiscount - discountAmount;

  bool get isOverdue {
    if (isPaid) return false;
    return DateTime.now().isAfter(dueDate);
  }

  String get status {
    if (isPaid) return 'Paid';
    if (isOverdue) return 'Overdue';
    return 'Unpaid';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoiceNumber': invoiceNumber,
    'invoiceDate': invoiceDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'customerName': customerName,
    'customerSurname': customerSurname,
    'customerCompany': customerCompany,
    'items': items.map((item) => item.toJson()).toList(),
    'discountPercentage': discountPercentage,
    'notes': notes,
    'isPaid': isPaid,
    'currency': currency,
  };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'],
    invoiceNumber: json['invoiceNumber'],
    invoiceDate: DateTime.parse(json['invoiceDate']),
    dueDate: DateTime.parse(json['dueDate']),
    customerName: json['customerName'],
    customerSurname: json['customerSurname'] ?? '',
    customerCompany: json['customerCompany'] ?? '',
    items: (json['items'] as List)
        .map((item) => InvoiceItem.fromJson(item))
        .toList(),
    discountPercentage: json['discountPercentage'] ?? 0.0,
    notes: json['notes'] ?? '',
    isPaid: json['isPaid'] ?? false,
    currency: json['currency'] ?? 'USD',
  );
}
