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
    var excel = Excel.createExcel();
    Sheet sheet = excel['Inventory'];

    // Append headers as dynamic types
    sheet.appendRow([
      // 'Barcode',         // String
      // 'Quantity',        // String or int
      // 'Expiration Date', // String or DateTime
      // 'Warehouse'        // String
    ]);

    // Append each product row
    for (var product in state) {
      sheet.appendRow([
        product['barcode'], // Assuming this is a string
        product['quantity'], // Assuming this is an integer
        product['expirationDate'], // Assuming this is a string or DateTime
        product['warehouse'], // Assuming this is a string
      ]);
    }

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/inventory.xlsx';
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    print('Exported to $path');
  }
}
