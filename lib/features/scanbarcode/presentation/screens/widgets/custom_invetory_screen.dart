import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/controller/product_cubit.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          if (products.isEmpty) {
            return Center(child: Text("No products added"));
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
