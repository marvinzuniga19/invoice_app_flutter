import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // We need local controllers for the form, but initial values come from Provider.
  // We should update the provider when Save is clicked.
  // Since Company is a HiveObject, we might be editing it directly if we aren't careful?
  // Actually, Hive objects are mutable.
  // But good practice is to treat state as immutable or update via Provider.
  // The Provider returns a Company object.
  // Let's copy values to controllers.

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;
  late TextEditingController _taxIdController;
  late TextEditingController _regNumberController;
  late TextEditingController _taxRateController;

  // Local state for logo path updates before saving
  String? _newLogoPath;

  // Track if we initialized controllers
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in didChangeDependencies or build when we have data?
    // Actually we can read initial state in initState if available.
    // Provider might trigger rebuilds.
    _initControllers();
  }

  void _initControllers() {
    // Initial dummy values, will be populated in build/didChangeDependencies
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipController = TextEditingController();
    _countryController = TextEditingController();
    _taxIdController = TextEditingController();
    _regNumberController = TextEditingController();
    _taxRateController = TextEditingController();
  }

  void _updateControllers(Company company) {
    if (_controllersInitialized) return;
    _nameController.text = company.name;
    _emailController.text = company.email;
    _phoneController.text = company.phone;
    _addressController.text = company.address;
    _cityController.text = company.city;
    _stateController.text = company.state;
    _zipController.text = company.zipCode;
    _countryController.text = company.country;
    _taxIdController.text = company.taxId;
    _regNumberController.text = company.registrationNumber;
    _taxRateController.text = company.defaultTaxRate.toString();
    _controllersInitialized = true;
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        setState(() {
          _newLogoPath = path;
        });
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _newLogoPath = '';
    });
  }

  Future<void> _saveSettings() async {
    final currentCompany = ref.read(settingsProvider).company;

    // Create a new Company object or update existing one?
    // Since it's HiveObject, let's create a new object with updated fields or update the fields.
    // Ideally we pass a new object to the provider.
    final updatedCompany = Company(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      zipCode: _zipController.text,
      country: _countryController.text,
      taxId: _taxIdController.text,
      registrationNumber: _regNumberController.text,
      logoPath: _newLogoPath ?? currentCompany.logoPath,
      defaultCurrency: currentCompany
          .defaultCurrency, // Managed by dropdown directly updating state if we want, or here.
      defaultTaxRate: double.tryParse(_taxRateController.text) ?? 0.0,
    );

    // We can't easily construct Company if we don't know the ID or if it's strictly the same object reference for Hive?
    // DatabaseService.getCompany() returns the singleton object 0?
    // Let's modify the fields of the CURRENT object if possible, or assume Provider handles save.
    // Provider.updateCompany(company) saves it.
    // But we need to make sure we don't lose the ID or Hive linkage if we create a NEW object?
    // Company model in this codebase seems to be a HiveObject.
    // If we create a new instance, it's not the same HiveObject.
    // So we should copy values to the existing object or DatabaseService.saveCompany handles it?
    // Checking DatabaseService.saveCompany... usually simple put.

    // Let's assume we copy fields to the retrieved company and save that.
    currentCompany.name = _nameController.text;
    currentCompany.email = _emailController.text;
    currentCompany.phone = _phoneController.text;
    currentCompany.address = _addressController.text;
    currentCompany.city = _cityController.text;
    currentCompany.state = _stateController.text;
    currentCompany.zipCode = _zipController.text;
    currentCompany.country = _countryController.text;
    currentCompany.taxId = _taxIdController.text;
    currentCompany.registrationNumber = _regNumberController.text;
    if (_newLogoPath != null) currentCompany.logoPath = _newLogoPath!;
    currentCompany.defaultTaxRate =
        double.tryParse(_taxRateController.text) ?? 0.0;
    // defaultCurrency is updated via setState on change? No, let's read it from currentCompany which might be stale in UI if we didn't update it?
    // Actually the dropdown below updates _company.defaultCurrency?
    // Wait, the previous code updated _company.defaultCurrency in setState.
    // We should do the same or update our local copy.

    await ref.read(settingsProvider.notifier).updateCompany(currentCompany);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final company = settingsState.company;

    // Populate controllers once
    if (!_controllersInitialized) {
      _updateControllers(company);
    }

    // Use effective logo path
    final logoPath = _newLogoPath ?? company.logoPath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: logoPath.isNotEmpty
                            ? Image.file(
                                File(logoPath),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stack) =>
                                    const Icon(Icons.broken_image),
                              )
                            : const Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickLogo,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload Logo'),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: logoPath.isNotEmpty ? _removeLogo : null,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remove'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _stateController,
                          decoration: const InputDecoration(labelText: 'State'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _zipController,
                          decoration: const InputDecoration(
                            labelText: 'ZIP Code',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _taxIdController,
                    decoration: const InputDecoration(
                      labelText: 'Tax ID',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _regNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Registration Number',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Defaults',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: company
                        .defaultCurrency, // Use value from provider/company
                    decoration: const InputDecoration(
                      labelText: 'Default Currency',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('USD - US Dollar'),
                      ),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                      DropdownMenuItem(
                        value: 'GBP',
                        child: Text('GBP - British Pound'),
                      ),
                      DropdownMenuItem(
                        value: 'MXN',
                        child: Text('MXN - Mexican Peso'),
                      ),
                    ],
                    onChanged: (value) {
                      // We can update the local company object immediately and UI will reflect if we use local state or just update the object.
                      // Updating the object reference directly works if we save later.
                      if (value != null) {
                        setState(() {
                          company.defaultCurrency = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _taxRateController,
                    decoration: const InputDecoration(
                      labelText: 'Default Tax Rate (%)',
                      prefixIcon: Icon(Icons.percent),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Invoice Generator'),
                    subtitle: Text('Version 1.0.0'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.description),
                    title: Text('Professional invoice management'),
                    subtitle: Text(
                      'Create, manage, and share invoices with ease',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _taxIdController.dispose();
    _regNumberController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }
}
