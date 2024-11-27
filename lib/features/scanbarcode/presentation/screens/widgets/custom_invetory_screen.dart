import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/controller/product_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch products when the InventoryScreen is built
    context.read<ProductCubit>().fetchProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => context.read<ProductCubit>().exportToExcel(),
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, List<Map<String, dynamic>>>(
        builder: (context, products) {
          // Show loading indicator if data is being fetched
          if (products.isEmpty) {
            return const Center(
                child: Text(
              'it is empty,please scan products',
            ));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text('Barcode: ${product['barcode']}'),
                subtitle: Text(
                    'Quantity: ${product['quantity']}, Expiry: ${product['expirationDate']}'),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(
                          context, product['barcode'], index);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text("Delete"),
                    ),
                  ],
                  icon: const Icon(Icons.delete),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            _showDeleteAllConfirmation(context);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.red),
          ),
          child: const Text(
            'Delete All Products',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  // Show delete confirmation for a single product
  void _showDeleteConfirmation(
      BuildContext context, String productId, int index) async {
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this product?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      // Delete the product from Firestore and update the state
      context.read<ProductCubit>().deleteProduct(productId, index);

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully!')),
      );
    }
  }

  // Show delete all confirmation
  void _showDeleteAllConfirmation(BuildContext context) async {
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Delete All"),
            content:
                const Text("Are you sure you want to delete all products?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      // Delete all products from Firestore and update the state
      context.read<ProductCubit>().deleteAllProducts();

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All products deleted successfully!')),
      );
    }
  }
}
