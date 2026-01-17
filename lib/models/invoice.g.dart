// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceAdapter extends TypeAdapter<Invoice> {
  @override
  final int typeId = 3;

  @override
  Invoice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Invoice(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      invoiceDate: fields[2] as DateTime,
      dueDate: fields[3] as DateTime,
      customerName: fields[4] as String,
      customerSurname: fields[11] as String,
      customerCompany: fields[12] as String,
      items: (fields[6] as List).cast<InvoiceItem>(),
      discountPercentage: fields[7] as double,
      notes: fields[8] as String,
      isPaid: fields[9] as bool,
      currency: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Invoice obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.invoiceDate)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.customerName)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.discountPercentage)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.isPaid)
      ..writeByte(10)
      ..write(obj.currency)
      ..writeByte(11)
      ..write(obj.customerSurname)
      ..writeByte(12)
      ..write(obj.customerCompany);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
