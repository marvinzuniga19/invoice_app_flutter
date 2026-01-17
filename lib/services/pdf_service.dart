import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoice.dart';
import '../models/company.dart';
import 'package:intl/intl.dart';

class PdfService {
  static final _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final _dateFormat = DateFormat('MMM dd, yyyy');

  static Future<pw.Document> generateInvoicePdf(
    Invoice invoice,
    Company company,
  ) async {
    final pdf = pw.Document();
    // Try to load logo bytes if a logo path is available
    Uint8List? logoBytes;
    if (company.logoPath.isNotEmpty) {
      try {
        final file = File(company.logoPath);
        if (await file.exists()) {
          logoBytes = await file.readAsBytes();
        }
      } catch (_) {
        logoBytes = null;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(company, logoBytes),
          pw.SizedBox(height: 20),
          _buildInvoiceInfo(invoice),
          pw.SizedBox(height: 20),
          _buildCustomerInfo(invoice),
          pw.SizedBox(height: 30),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 20),
          _buildTotals(invoice),
          if (invoice.notes.isNotEmpty) ...[
            pw.SizedBox(height: 30),
            _buildNotes(invoice.notes),
          ],
          pw.Spacer(),
          _buildFooter(company),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(Company company, Uint8List? logoBytes) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logoBytes != null)
              pw.Container(
                width: 80,
                height: 80,
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  fit: pw.BoxFit.contain,
                ),
              ),
            pw.SizedBox(height: 8),
            pw.Text(
              company.name,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 8),
            if (company.address.isNotEmpty)
              pw.Text(company.address, style: const pw.TextStyle(fontSize: 10)),
            if (company.city.isNotEmpty)
              pw.Text(
                '${company.city}, ${company.state} ${company.zipCode}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            if (company.country.isNotEmpty)
              pw.Text(company.country, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 4),
            if (company.email.isNotEmpty)
              pw.Text(company.email, style: const pw.TextStyle(fontSize: 10)),
            if (company.phone.isNotEmpty)
              pw.Text(company.phone, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 32,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoColumn('Invoice Number', invoice.invoiceNumber),
          _buildInfoColumn(
            'Invoice Date',
            _dateFormat.format(invoice.invoiceDate),
          ),
          _buildInfoColumn('Due Date', _dateFormat.format(invoice.dueDate)),
          _buildInfoColumn('Status', invoice.status),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoColumn(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(Invoice invoice) {
    String displayName = invoice.customerName;
    if (invoice.customerSurname.isNotEmpty) {
      displayName += ' ${invoice.customerSurname}';
    }
    if (invoice.customerCompany.isNotEmpty) {
      if (displayName.isNotEmpty) {
        displayName += '\n${invoice.customerCompany}';
      } else {
        displayName = invoice.customerCompany;
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Bill To:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            displayName,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue900),
          children: [
            _buildTableHeader('Description'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Unit Price'),
            _buildTableHeader('Tax %'),
            _buildTableHeader('Amount'),
          ],
        ),
        // Items
        ...invoice.items.map(
          (item) => pw.TableRow(
            children: [
              _buildTableCell(item.description, align: pw.TextAlign.left),
              _buildTableCell(item.quantity.toString()),
              _buildTableCell(_currencyFormat.format(item.unitPrice)),
              _buildTableCell('${item.taxPercentage.toStringAsFixed(1)}%'),
              _buildTableCell(_currencyFormat.format(item.total)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {pw.TextAlign? align}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: align ?? pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTotals(Invoice invoice) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            _buildTotalRow('Subtotal', invoice.subtotal),
            _buildTotalRow('Tax', invoice.totalTax),
            if (invoice.discountPercentage > 0) ...[
              _buildTotalRow(
                'Discount (${invoice.discountPercentage.toStringAsFixed(1)}%)',
                -invoice.discountAmount,
              ),
            ],
            pw.Divider(thickness: 2),
            _buildTotalRow('Total', invoice.total, isBold: true, fontSize: 14),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 11,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            _currencyFormat.format(amount),
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotes(String notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notes:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(notes, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(Company company) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
