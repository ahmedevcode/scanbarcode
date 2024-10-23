import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ProductCubit extends Cubit<List<Map<String, dynamic>>> {
  ProductCubit() : super([]);

  // Add product to the state and Firestore
  void addProduct(
      String barcode, int quantity, DateTime expirationDate, String warehouse) {
    final product = {
      'barcode': barcode,
      'quantity': quantity,
      'expirationDate': expirationDate.toIso8601String(),
      'warehouse': warehouse,
    };
    FirebaseFirestore.instance.collection('inventory').add(product);
    emit([...state, product]);
  }

  // Fetch products from Firestore
  void fetchProducts() async {
    final products =
        await FirebaseFirestore.instance.collection('inventory').get();
    emit(products.docs.map((doc) => doc.data()).toList());
  }

  Future<void> exportToExcel() async {
    // Create a new Excel file
    var excel = Excel.createExcel(); // This creates a new Excel document
    Sheet sheet = excel['Inventory']; // Create a new sheet named 'Inventory'

    // Append headers
    sheet.appendRow([
      // 'barcode',         // Header for barcode
      // 'Quantity',        // Header for quantity
      // 'Expiration Date', // Header for expiration date
      // 'Warehouse',       // Header for warehouse
    ]);

    // Append each product row
    for (var product in state) {
      sheet.appendRow([
        product['barcode'], // Assuming this is a string
        product['quantity'], // Assuming this is an integer
        product['expirationDate'], // Assuming this is an ISO formatted string
        product['warehouse'], // Assuming this is a string
      ]);
    }

    // Save to file
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/inventory.xlsx';
      File file = File(path);

      // Create the file if it does not exist and write the Excel data
      await file.create(recursive: true);
      await file.writeAsBytes(await excel.encode()!);

      print('Exported to $path');
    } catch (e) {
      print('Failed to export to Excel: $e');
    }
  }
}
