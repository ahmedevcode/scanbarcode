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
        title: Text("Inventory"),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () => context.read<ProductCubit>().exportToExcel(),
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, List<Map<String, dynamic>>>(
        builder: (context, products) {
          // Show loading indicator if data is being fetched
          if (products.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text('Barcode: ${product['barcode']}'),
                subtitle: Text(
                    'Quantity: ${product['quantity']}, Expiry: ${product['expirationDate']}'),
              );
            },
          );
        },
      ),
    );
  }
}
