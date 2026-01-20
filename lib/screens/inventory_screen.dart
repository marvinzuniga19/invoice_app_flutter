import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import 'product_form_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  final bool isPicker;

  const InventoryScreen({super.key, this.isPicker = false});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(inventoryListProvider.notifier)
                  .deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted successfully')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(inventoryListProvider); // Watch for changes
    final products = ref
        .read(inventoryListProvider.notifier)
        .search(_searchQuery);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
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
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No products found'
                          : 'No matching products',
                    ),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: product.imagePath != null
                              ? FileImage(File(product.imagePath!))
                              : null,
                          child: product.imagePath == null
                              ? Text(product.name[0].toUpperCase())
                              : null,
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          '${product.sku ?? 'No SKU'} • Stock: ${product.stockQuantity.toStringAsFixed(0)}',
                        ),
                        trailing: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () async {
                          if (widget.isPicker) {
                            Navigator.pop(context, product);
                            return;
                          }
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductFormScreen(product: product),
                            ),
                          );
                          ref.invalidate(inventoryListProvider);
                        },
                        onLongPress: () => _deleteProduct(product),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: widget.isPicker
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductFormScreen(),
                  ),
                );
                ref.invalidate(inventoryListProvider);
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
