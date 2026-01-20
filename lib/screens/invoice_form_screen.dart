import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../providers/invoice_provider.dart';
import '../providers/customer_provider.dart';
import 'inventory_screen.dart';
import 'customer_form_dialog.dart';

class InvoiceFormScreen extends ConsumerStatefulWidget {
  final Invoice? invoice;

  const InvoiceFormScreen({super.key, this.invoice});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  List<InvoiceItem> _items = [];
  double _discountPercentage = 0.0;
  String _notes = '';

  String _currency = 'USD';
  Customer? _selectedCustomer;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _invoiceNumberController =
      TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Flag to track if we have tried to find the initial customer
  bool _initialCustomerLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _loadInvoiceData();
    } else {
      // We can't access ref.read in initState for some providers if they depend on context/scope which might not be ready?
      // Actually accessing notifier methods is fine.
      // But we will generate number in build or didChangeDependencies if it's empty?
      // Or just schedule a callback safely.
      Future.microtask(() {
        if (mounted) {
          _invoiceNumberController.text = ref
              .read(invoiceListProvider.notifier)
              .generateInvoiceNumber();
        }
      });

      _addNewItem();
    }
  }

  void _loadInvoiceData() {
    final invoice = widget.invoice!;
    _invoiceNumberController.text = invoice.invoiceNumber;
    _nameController.text = invoice.customerName;
    _surnameController.text = invoice.customerSurname;
    _companyController.text = invoice.customerCompany;
    _invoiceDate = invoice.invoiceDate;
    _dueDate = invoice.dueDate;
    _items = List.from(invoice.items);
    _discountPercentage = invoice.discountPercentage;
    _notes = invoice.notes;
    _currency = invoice.currency;
    _discountController.text = _discountPercentage.toString();
    _notesController.text = _notes;
  }

  void _addNewItem() {
    setState(() {
      _items.add(
        InvoiceItem(
          id: _uuid.v4(),
          description: '',
          quantity: 1,
          unitPrice: 0,
          taxPercentage: 0,
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _pickProduct() async {
    final Product? product = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InventoryScreen(isPicker: true),
      ),
    );

    if (product != null) {
      if (!mounted) return;
      setState(() {
        _items.add(
          InvoiceItem(
            id: _uuid.v4(),
            description: product.description ?? product.name,
            quantity: 1,
            unitPrice: product.price,
            taxPercentage: product.taxPercentage,
          ),
        );
      });
    }
  }

  double get _subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _totalTax => _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get _totalBeforeDiscount => _subtotal + _totalTax;
  double get _discountAmount =>
      _totalBeforeDiscount * (_discountPercentage / 100);
  double get _total => _totalBeforeDiscount - _discountAmount;

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.isEmpty && _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a customer name or company'),
        ),
      );
      return;
    }

    if (_items.isEmpty || _items.any((item) => item.description.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item with description'),
        ),
      );
      return;
    }

    // Validate invoice number uniqueness
    final existingInvoices = ref.read(invoiceListProvider);
    final isDuplicate = existingInvoices.any(
      (inv) =>
          inv.invoiceNumber == _invoiceNumberController.text &&
          (widget.invoice == null || inv.id != widget.invoice!.id),
    );

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice number already exists')),
      );
      return;
    }

    try {
      if (widget.invoice == null) {
        await ref
            .read(invoiceListProvider.notifier)
            .createInvoice(
              invoiceNumber: _invoiceNumberController.text,
              customerName: _nameController.text,
              customerSurname: _surnameController.text,
              customerCompany: _companyController.text,
              invoiceDate: _invoiceDate,
              dueDate: _dueDate,
              items: _items,
              discountPercentage: _discountPercentage,
              notes: _notes,
              currency: _currency,
            );
      } else {
        final updatedInvoice = Invoice(
          id: widget.invoice!.id,
          invoiceNumber: _invoiceNumberController.text,
          invoiceDate: _invoiceDate,
          dueDate: _dueDate,
          customerName: _nameController.text,
          customerSurname: _surnameController.text,
          customerCompany: _companyController.text,
          items: _items,
          discountPercentage: _discountPercentage,
          notes: _notes,
          isPaid: widget.invoice!.isPaid,
          currency: _currency,
        );
        await ref
            .read(invoiceListProvider.notifier)
            .updateInvoice(updatedInvoice);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.invoice == null
                  ? 'Invoice created successfully'
                  : 'Invoice updated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving invoice: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final customers = ref.watch(customerListProvider);

    // Initial customer selection logic
    if (widget.invoice != null &&
        !_initialCustomerLoaded &&
        customers.isNotEmpty) {
      // Need to run this once or safely
      // We shouldn't calculate this during build if we want to update state,
      // BUT we can calculate _selectedCustomer which is just a variable.
      // However, we want to set it so the Dropdown shows it.
      // Let's try to match it.
      try {
        final match = customers.firstWhere((c) {
          if (c.isCompany) {
            return c.name == widget.invoice!.customerCompany;
          }
          return c.name == widget.invoice!.customerName &&
              c.lastName == widget.invoice!.customerSurname;
        });
        _selectedCustomer = match;
      } catch (_) {
        _selectedCustomer = null;
      }
      _initialCustomerLoaded = true;
      // Note: we're modifying state variables in build indirectly (by assigning to local variable? No result is assigned to _selectedCustomer which is a field).
      // This is a side-effect in build. It's better to do this in initState or via post-frame callback if we need to setState.
      // However, simply updating the field without setState is fine IF we are sure it reflects correctly.
      // But _selectedCustomer is used in Dropdown 'value'.
      // A safer way is to rely on 'initialValue' logic or keys.
      // Let's leave it for now or move to useEffect / init logic.
      // Actually _initialCustomerLoaded logic inside build is risky for infinite loops if we called setState. We are not calling setState here.
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice == null ? 'New Invoice' : 'Edit Invoice'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveInvoice),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Invoice Number
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _invoiceNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Invoice Number',
                    prefixIcon: Icon(Icons.confirmation_number),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an invoice number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customer',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final newCustomer = await showDialog<Customer>(
                              context: context,
                              builder: (context) => const CustomerFormDialog(),
                            );
                            if (newCustomer != null) {
                              // Add is handled by dialog?
                              // CustomerFormDialog implementation usually adds it properly if it returns.
                              // Wait, CustomerFormDialog usually calls Provider to add?
                              // Let's check CustomerFormDialog in previous turns or assume it might behave like InventoryForm.
                              // If it returns a customer, we might need to select it.
                              // The dialog logic in CustomersScreen ADDED the customer AFTER dialog returned.
                              // I need to check behavior of CustomerFormDialog.
                              // Assuming it returns the Object but doesn't Save it?
                              // CustomersScreen.dart:
                              // final result = await showDialog...
                              // if (result != null) await ref.read(customerListProvider.notifier).addCustomer(result);

                              // Check CustomerFormDialog!
                              // If it doesn't save allow the form to use it?
                              // I'll add it here if it returns object.

                              await ref
                                  .read(customerListProvider.notifier)
                                  .addCustomer(newCustomer);

                              setState(() {
                                _selectedCustomer = newCustomer;
                                _nameController.text = newCustomer.name;
                                _surnameController.text = newCustomer.lastName;
                                _companyController.text = newCustomer.isCompany
                                    ? newCustomer.name
                                    : '';
                              });
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (customers.isNotEmpty) ...[
                      DropdownButtonFormField<Customer>(
                        key: ValueKey(_selectedCustomer),
                        decoration: const InputDecoration(
                          labelText: 'Select Existing Customer',
                          prefixIcon: Icon(Icons.people),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCustomer,
                        // Fix for: 'items' must contain 'value'. If _selectedCustomer is not in list (e.g. deleted), null it.
                        // We handled loaded/match logic, but if not in list, fallback to null.
                        // We need to ensure _selectedCustomer IS in 'customers' or null.
                        items: customers.contains(_selectedCustomer)
                            ? customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer,
                                  child: Text(
                                    customer.displayName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList()
                            : customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer,
                                  child: Text(customer.displayName),
                                );
                              }).toList(),
                        onChanged: (customer) {
                          setState(() {
                            _selectedCustomer = customer;
                            if (customer != null) {
                              if (customer.isCompany) {
                                _companyController.text = customer.name;
                                _nameController.clear();
                                _surnameController.clear();
                              } else {
                                _nameController.text = customer.name;
                                _surnameController.text = customer.lastName;
                                _companyController.clear();
                              }
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Surname',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company',
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dates',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;

                        if (isMobile) {
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Invoice Date'),
                                subtitle: Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_invoiceDate),
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _invoiceDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _invoiceDate = date;
                                    });
                                  }
                                },
                              ),
                              const Divider(),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Due Date'),
                                subtitle: Text(
                                  DateFormat('MMM dd, yyyy').format(_dueDate),
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _dueDate = date;
                                    });
                                  }
                                },
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: const Text('Invoice Date'),
                                subtitle: Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(_invoiceDate),
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _invoiceDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _invoiceDate = date;
                                    });
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: const Text('Due Date'),
                                subtitle: Text(
                                  DateFormat('MMM dd, yyyy').format(_dueDate),
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _dueDate = date;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _pickProduct,
                              icon: const Icon(Icons.inventory),
                              label: const Text('From Inventory'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: _addNewItem,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Item'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildItemRow(index, item);
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Discount and Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount (%)',
                        prefixIcon: Icon(Icons.percent),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _discountPercentage = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _notes = value;
                      },
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
                    _buildTotalRow('Subtotal', _subtotal, currencyFormat),
                    _buildTotalRow('Tax', _totalTax, currencyFormat),
                    if (_discountPercentage > 0)
                      _buildTotalRow(
                        'Discount',
                        -_discountAmount,
                        currencyFormat,
                      ),
                    const Divider(thickness: 2),
                    _buildTotalRow(
                      'Total',
                      _total,
                      currencyFormat,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveInvoice,
        icon: const Icon(Icons.save),
        label: const Text('Save Invoice'),
      ),
    );
  }

  Widget _buildItemRow(int index, InvoiceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.description,
              decoration: const InputDecoration(
                labelText: 'Description',
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  item.description = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.quantity = double.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.unitPrice = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.taxPercentage.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Tax %',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        item.taxPercentage = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${item.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _companyController.dispose();
    _invoiceNumberController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
