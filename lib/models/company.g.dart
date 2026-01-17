// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyAdapter extends TypeAdapter<Company> {
  @override
  final int typeId = 2;

  @override
  Company read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Company(
      name: fields[0] as String,
      email: fields[1] as String,
      phone: fields[2] as String,
      address: fields[3] as String,
      city: fields[4] as String,
      state: fields[5] as String,
      zipCode: fields[6] as String,
      country: fields[7] as String,
      taxId: fields[8] as String,
      registrationNumber: fields[9] as String,
      logoPath: fields[10] as String,
      defaultCurrency: fields[11] as String,
      defaultTaxRate: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Company obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.state)
      ..writeByte(6)
      ..write(obj.zipCode)
      ..writeByte(7)
      ..write(obj.country)
      ..writeByte(8)
      ..write(obj.taxId)
      ..writeByte(9)
      ..write(obj.registrationNumber)
      ..writeByte(10)
      ..write(obj.logoPath)
      ..writeByte(11)
      ..write(obj.defaultCurrency)
      ..writeByte(12)
      ..write(obj.defaultTaxRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
