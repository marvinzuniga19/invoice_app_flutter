import 'package:hive/hive.dart';

part 'company.g.dart';

@HiveType(typeId: 2)
class Company extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String address;

  @HiveField(4)
  String city;

  @HiveField(5)
  String state;

  @HiveField(6)
  String zipCode;

  @HiveField(7)
  String country;

  @HiveField(8)
  String taxId;

  @HiveField(9)
  String registrationNumber;

  @HiveField(10)
  String logoPath;

  @HiveField(11)
  String defaultCurrency;

  @HiveField(12)
  double defaultTaxRate;

  Company({
    this.name = 'My Company',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.country = '',
    this.taxId = '',
    this.registrationNumber = '',
    this.logoPath = '',
    this.defaultCurrency = 'USD',
    this.defaultTaxRate = 0.0,
  });

  String get fullAddress {
    List<String> parts = [];
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (zipCode.isNotEmpty) parts.add(zipCode);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}
