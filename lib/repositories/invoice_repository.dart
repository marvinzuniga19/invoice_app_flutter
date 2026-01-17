import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';

class InvoiceRepository {
  static Future<String> savePdf(Invoice invoice) async {
    final company = DatabaseService.getCompany();
    final pdf = await PdfService.generateInvoicePdf(invoice, company);
    final bytes = await pdf.save();

    final directory = await getApplicationDocumentsDirectory();
    final invoiceDir = Directory('${directory.path}/factura');

    if (!await invoiceDir.exists()) {
      await invoiceDir.create(recursive: true);
    }

    final file = File(
      '${invoiceDir.path}/invoice_${invoice.invoiceNumber}.pdf',
    );
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
