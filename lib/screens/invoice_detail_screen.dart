import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';
import '../services/database_service.dart';
import '../services/invoice_service.dart';
import '../services/pdf_service.dart';
import '../repositories/invoice_repository.dart';
import 'invoice_form_screen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Invoice _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  Future<void> _generateAndPreviewPdf() async {
    try {
      final company = DatabaseService.getCompany();
      final pdf = await PdfService.generateInvoicePdf(_invoice, company);

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  Future<void> _shareInvoice() async {
    try {
      final company = DatabaseService.getCompany();
      final pdf = await PdfService.generateInvoicePdf(_invoice, company);
      final bytes = await pdf.save();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice_${_invoice.invoiceNumber}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Invoice ${_invoice.invoiceNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing invoice: $e')));
      }
    }
  }

  Future<void> _savePdfLocally() async {
    try {
      final filePath = await InvoiceRepository.savePdf(_invoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to factura folder'),
            action: SnackBarAction(
              label: 'View Path',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('PDF Saved'),
                    content: SelectableText(filePath),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving PDF: $e')));
      }
    }
  }

  Future<void> _togglePaidStatus() async {
    setState(() {
      _invoice.isPaid = !_invoice.isPaid;
    });
    await InvoiceService.updateInvoice(_invoice);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _invoice.isPaid ? 'Marked as paid' : 'Marked as unpaid',
          ),
        ),
      );
    }
  }

  Future<void> _deleteInvoice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await InvoiceService.deleteInvoice(_invoice.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invoice deleted')));
      }
    }
  }

  Future<void> _duplicateInvoice() async {
    final newInvoice = await InvoiceService.duplicateInvoice(_invoice);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceFormScreen(invoice: newInvoice),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Construct display name logic same as PdfService or similar
    String customerDisplayName = _invoice.customerName;
    if (_invoice.customerSurname.isNotEmpty) {
      customerDisplayName += ' ${_invoice.customerSurname}';
    }
    if (_invoice.customerCompany.isNotEmpty) {
      // If company exists
      if (customerDisplayName.isNotEmpty) {
        customerDisplayName += ' (${_invoice.customerCompany})';
      } else {
        customerDisplayName = _invoice.customerCompany;
      }
    }

    Color statusColor;
    Color statusBgColor;

    switch (_invoice.status) {
      case 'Paid':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
        break;
      case 'Overdue':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFFEF3C7);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_invoice.invoiceNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceFormScreen(invoice: _invoice),
                ),
              );
              setState(() {
                _invoice = DatabaseService.getInvoice(_invoice.id)!;
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _duplicateInvoice,
                child: const Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: _deleteInvoice,
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _invoice.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Invoice Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoice Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Invoice Number', _invoice.invoiceNumber),
                  _buildInfoRow(
                    'Invoice Date',
                    dateFormat.format(_invoice.invoiceDate),
                  ),
                  _buildInfoRow(
                    'Due Date',
                    dateFormat.format(_invoice.dueDate),
                  ),
                  _buildInfoRow('Currency', _invoice.currency),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Customer Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Name', _invoice.customerName),
                  if (_invoice.customerSurname.isNotEmpty)
                    _buildInfoRow('Surname', _invoice.customerSurname),
                  if (_invoice.customerCompany.isNotEmpty)
                    _buildInfoRow('Company', _invoice.customerCompany),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Items
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ..._invoice.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.quantity} × ${currencyFormat.format(item.unitPrice)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                currencyFormat.format(item.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (item.taxPercentage > 0)
                            Text(
                              'Tax: ${item.taxPercentage}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Totals
          Card(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTotalRow('Subtotal', _invoice.subtotal, currencyFormat),
                  _buildTotalRow('Tax', _invoice.totalTax, currencyFormat),
                  if (_invoice.discountPercentage > 0)
                    _buildTotalRow(
                      'Discount (${_invoice.discountPercentage}%)',
                      -_invoice.discountAmount,
                      currencyFormat,
                    ),
                  const Divider(thickness: 2),
                  _buildTotalRow(
                    'Total',
                    _invoice.total,
                    currencyFormat,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),

          // Notes
          if (_invoice.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_invoice.notes),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 4,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: _togglePaidStatus,
                  icon: Icon(
                    _invoice.isPaid ? Icons.close : Icons.check,
                    size: 18,
                  ),
                  label: Text(
                    _invoice.isPaid ? 'Unpaid' : 'Paid',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _generateAndPreviewPdf,
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('View', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _savePdfLocally,
                  icon: const Icon(Icons.save_alt, size: 18),
                  label: const Text('Save', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _shareInvoice,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount,
    NumberFormat format, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            format.format(amount),
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
