import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_app/models/invoice.dart';
import 'package:invoice_app/models/invoice_item.dart';

void main() {
  group('Invoice Model Calculations', () {
    test('calculate total correctly with single item', () {
      final item = InvoiceItem(
        id: '1',
        description: 'Test Item',
        quantity: 1,
        unitPrice: 100.0,
      );

      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        customerName: 'Test Customer',
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now(),
        items: [item],
        currency: 'USD',
      );

      expect(invoice.subtotal, 100.0);
      expect(invoice.totalTax, 0.0);
      expect(invoice.total, 100.0);
    });

    test('calculate tax correctly', () {
      final item = InvoiceItem(
        id: '2',
        description: 'Taxable Item',
        quantity: 1,
        unitPrice: 100.0,
        taxPercentage: 10.0,
      );

      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        customerName: 'Test Customer',
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now(),
        items: [item],
        currency: 'USD',
      );

      expect(invoice.subtotal, 100.0);
      expect(invoice.totalTax, 10.0);
      expect(invoice.total, 110.0);
    });

    test('calculate global discount correctly', () {
      final item = InvoiceItem(
        id: '3',
        description: 'Item',
        quantity: 1,
        unitPrice: 100.0,
      );

      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        customerName: 'Test Customer',
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now(),
        items: [item],
        discountPercentage: 10.0,
        currency: 'USD',
      );

      // Subtotal: 100
      // Discount: 10% of 100 = 10
      // Tax: 0
      // Total: 90

      expect(invoice.subtotal, 100.0);
      expect(invoice.discountAmount, 10.0);
      expect(invoice.total, 90.0);
    });

    test('calculate complex invoice with multiple items, tax and discount', () {
      // Item 1: 2 * 50 = 100, Tax 10% = 10 -> Total 110
      // Item 2: 1 * 200 = 200, Tax 0% = 0   -> Total 200
      // Subtotal Sum: 300
      // Discount 10% on Subtotal (300) = 30
      // Tax is calculated on (Subtotal - Discount)? Or Tax is calculated per item?
      // Logic in InvoiceGetter:
      // totalTax = items.fold(0, (sum, item) => sum + item.taxAmount);
      // discountAmount = subtotal * (discountPercentage / 100);
      // total = subtotal - discountAmount + totalTax;
      // Note: Usually discount applies before tax? or after?
      // The current implementation accumulates tax from items independently of global discount.

      final item1 = InvoiceItem(
        id: '4',
        description: 'Item 1',
        quantity: 2,
        unitPrice: 50.0,
        taxPercentage: 10.0,
      );

      final item2 = InvoiceItem(
        id: '5',
        description: 'Item 2',
        quantity: 1,
        unitPrice: 200.0,
        taxPercentage: 0.0,
      );

      final invoice = Invoice(
        id: '1',
        invoiceNumber: 'INV-001',
        customerName: 'Test Customer',
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now(),
        items: [item1, item2],
        discountPercentage: 10.0,
        currency: 'USD',
      );

      expect(invoice.subtotal, 300.0); // 100 + 200
      expect(invoice.totalTax, 10.0); // 10% of 100 + 0
      expect(invoice.discountAmount, 31.0); // 10% of 310 (Subtotal + Tax)

      // Total = 310 - 31 = 279
      expect(invoice.total, 279.0);
    });
  });
}
