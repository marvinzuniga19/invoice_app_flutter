import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';

class CustomerFormDialog extends StatefulWidget {
  final Customer? customer;

  const CustomerFormDialog({super.key, this.customer});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxIdController = TextEditingController();
  bool _isCompany = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _lastNameController.text = widget.customer!.lastName;
      _emailController.text = widget.customer!.email;
      _phoneController.text = widget.customer!.phone;
      _taxIdController.text = widget.customer!.taxId;
      _isCompany = widget.customer!.isCompany;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer != null ? 'Edit Customer' : 'New Customer'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Is Company'),
                subtitle: Text(
                  _isCompany ? 'Company/Business' : 'Individual Person',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                value: _isCompany,
                onChanged: (value) {
                  setState(() {
                    _isCompany = value;
                    if (value) {
                      _lastNameController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _isCompany ? 'Company Name *' : 'First Name *',
                  prefixIcon: Icon(_isCompany ? Icons.business : Icons.person),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              if (!_isCompany) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _taxIdController,
                decoration: const InputDecoration(
                  labelText: 'Tax ID / Fiscal Number',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isCompany
                        ? 'Company name is required'
                        : 'First name is required',
                  ),
                ),
              );
              return;
            }

            final newCustomer = Customer(
              id: widget.customer?.id ?? const Uuid().v4(),
              name: _nameController.text,
              lastName: _lastNameController.text,
              isCompany: _isCompany,
              email: _emailController.text,
              phone: _phoneController.text,
              taxId: _taxIdController.text,
            );

            // await DatabaseService.saveCustomer(newCustomer); // Handled by caller via Riverpod
            if (context.mounted) {
              Navigator.pop(context, newCustomer);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }
}
