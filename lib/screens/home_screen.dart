import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import '../widgets/invoice_card.dart';
import '../widgets/stats_card.dart';
import 'invoice_form_screen.dart';
import 'invoice_detail_screen.dart';
import 'customers_screen.dart';
import 'settings_screen.dart';
import 'inventory_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Invoice> _getFilteredInvoices() {
    List<Invoice> invoices = InvoiceService.getAllInvoices();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      invoices = InvoiceService.searchInvoices(_searchQuery);
    }

    // Apply status filter
    if (_filterStatus != 'All') {
      invoices = invoices.where((inv) => inv.status == _filterStatus).toList();
    }

    // Sort by date (newest first)
    invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

    return invoices;
  }

  void _navigateToInvoiceForm([Invoice? invoice]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceFormScreen(invoice: invoice),
      ),
    );
    setState(() {});
  }

  void _navigateToInvoiceDetail(Invoice invoice) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(invoice: invoice),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final stats = InvoiceService.getStatistics();
    final invoices = _getFilteredInvoices();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Generator'),
        // Removed actions as they are now in the drawer
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Invoice App',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Customers'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomersScreen(),
                  ),
                );
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                );
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
                setState(() {});
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Statistics Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1, // Adjusted to prevent overflow
              children: [
                StatsCard(
                  icon: Icons.receipt_long,
                  title: 'Total Invoices',
                  value: '${stats['totalInvoices']}',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFDEEBFF),
                ),
                StatsCard(
                  icon: Icons.attach_money,
                  title: 'Total Revenue',
                  value: currencyFormat.format(stats['totalRevenue']),
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFD1FAE5),
                ),
                StatsCard(
                  icon: Icons.check_circle,
                  title: 'Paid',
                  value: '${stats['paidCount']}',
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFD1FAE5),
                ),
                StatsCard(
                  icon: Icons.warning,
                  title: 'Overdue',
                  value: '${stats['overdueCount']}',
                  color: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEE2E2),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search invoices...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'All', child: Text('All')),
                    const PopupMenuItem(value: 'Paid', child: Text('Paid')),
                    const PopupMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                    const PopupMenuItem(
                      value: 'Overdue',
                      child: Text('Overdue'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter indicator
            if (_filterStatus != 'All')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Chip(
                  label: Text('Filter: $_filterStatus'),
                  onDeleted: () {
                    setState(() {
                      _filterStatus = 'All';
                    });
                  },
                ),
              ),

            // Invoices List
            if (invoices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No invoices found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first invoice to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...invoices.map(
                (invoice) => InvoiceCard(
                  invoice: invoice,
                  onTap: () => _navigateToInvoiceDetail(invoice),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToInvoiceForm(),
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }
}
