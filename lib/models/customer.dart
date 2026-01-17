import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  bool isCompany;

  @HiveField(4)
  String email;

  @HiveField(5)
  String phone;

  @HiveField(6)
  String taxId;

  Customer({
    required this.id,
    required this.name,
    this.lastName = '',
    this.isCompany = false,
    this.email = '',
    this.phone = '',
    this.taxId = '',
  });

  /// Returns the full display name
  /// For companies: just the name
  /// For individuals: name + lastName
  String get displayName {
    if (isCompany || lastName.isEmpty) {
      return name;
    }
    return '$name $lastName';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lastName': lastName,
    'isCompany': isCompany,
    'email': email,
    'phone': phone,
    'taxId': taxId,
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    name: json['name'],
    lastName: json['lastName'] ?? '',
    isCompany: json['isCompany'] ?? false,
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    taxId: json['taxId'] ?? '',
  );
}
