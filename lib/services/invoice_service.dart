import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';

class InvoiceService {
  static const _uuid = Uuid();

  // Generate next invoice number
  static String generateInvoiceNumber() {
    final invoices = DatabaseService.getAllInvoices();
    if (invoices.isEmpty) {
      return 'INV-0001';
    }

    // Get the highest invoice number
    int maxNumber = 0;
    for (var invoice in invoices) {
      final numberPart = invoice.invoiceNumber.split('-').last;
      final number = int.tryParse(numberPart) ?? 0;
      if (number > maxNumber) {
        maxNumber = number;
      }
    }

    return 'INV-${(maxNumber + 1).toString().padLeft(4, '0')}';
  }

  // Create new invoice
  static Future<Invoice> createInvoice({
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
    final invoice = Invoice(
      id: _uuid.v4(),
      invoiceNumber: invoiceNumber ?? generateInvoiceNumber(),
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      customerName: customerName,
      customerSurname: customerSurname,
      customerCompany: customerCompany,
      items: items,
      discountPercentage: discountPercentage,
      notes: notes,
      currency: currency,
    );

    await DatabaseService.saveInvoice(invoice);
    return invoice;
  }

  // Update invoice
  static Future<void> updateInvoice(Invoice invoice) async {
    await DatabaseService.saveInvoice(invoice);
  }

  // Delete invoice
  static Future<void> deleteInvoice(String id) async {
    await DatabaseService.deleteInvoice(id);
  }

  // Get all invoices
  static List<Invoice> getAllInvoices() {
    return DatabaseService.getAllInvoices();
  }

  // Search invoices
  static List<Invoice> searchInvoices(String query) {
    final invoices = getAllInvoices();
    if (query.isEmpty) return invoices;

    final lowerQuery = query.toLowerCase();
    return invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(lowerQuery) ||
          invoice.customerName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter by status
  static List<Invoice> filterByStatus(String status) {
    final invoices = getAllInvoices();
    if (status == 'All') return invoices;

    return invoices.where((invoice) => invoice.status == status).toList();
  }

  // Get invoice statistics
  static Map<String, dynamic> getStatistics() {
    final invoices = getAllInvoices();

    double totalRevenue = 0;
    int paidCount = 0;
    int unpaidCount = 0;
    int overdueCount = 0;

    for (var invoice in invoices) {
      if (invoice.isPaid) {
        totalRevenue += invoice.total;
        paidCount++;
      } else if (invoice.isOverdue) {
        overdueCount++;
      } else {
        unpaidCount++;
      }
    }

    return {
      'totalInvoices': invoices.length,
      'totalRevenue': totalRevenue,
      'paidCount': paidCount,
      'unpaidCount': unpaidCount,
      'overdueCount': overdueCount,
    };
  }

  // Duplicate invoice
  static Future<Invoice> duplicateInvoice(Invoice original) async {
    final newItems = original.items
        .map(
          (item) => InvoiceItem(
            id: _uuid.v4(),
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            taxPercentage: item.taxPercentage,
          ),
        )
        .toList();

    return createInvoice(
      customerName: original.customerName,
      customerSurname: original.customerSurname,
      customerCompany: original.customerCompany,
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      items: newItems,
      discountPercentage: original.discountPercentage,
      notes: original.notes,
      currency: original.currency,
    );
  }
}
