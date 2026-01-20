import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/invoice_service.dart';

part 'invoice_provider.g.dart';

@riverpod
class InvoiceList extends _$InvoiceList {
  @override
  List<Invoice> build() {
    return InvoiceService.getAllInvoices();
  }

  Future<void> createInvoice({
    required String customerName,
    String? invoiceNumber,
    String customerSurname = '',
    String customerCompany = '',
    required DateTime invoiceDate,
    required DateTime dueDate,
    required List<InvoiceItem> items,
    double discountPercentage = 0.0,
    String notes = '',
    String currency = 'USD',
  }) async {
    await InvoiceService.createInvoice(
      customerName: customerName,
      invoiceNumber: invoiceNumber,
      customerSurname: customerSurname,
      customerCompany: customerCompany,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      items: items,
      discountPercentage: discountPercentage,
      notes: notes,
      currency: currency,
    );
    ref.invalidateSelf();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    await InvoiceService.updateInvoice(invoice);
    ref.invalidateSelf();
  }

  String generateInvoiceNumber() {
    // Usage of service method or local logic.
    // Service method reads from DB, which is fine.
    return InvoiceService.generateInvoiceNumber();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> deleteInvoice(String id) async {
    await InvoiceService.deleteInvoice(id);
    ref.invalidateSelf();
  }
}
