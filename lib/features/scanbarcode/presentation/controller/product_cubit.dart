import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // For Workbook
import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // For Workbook
import 'package:path_provider/path_provider.dart'; // For accessing directories
import 'dart:io'; // For file operations
import 'package:share_plus/share_plus.dart';

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

  // Delete a single product from Firestore and update state
  void deleteProduct(String productId, int index) async {
    await FirebaseFirestore.instance
        .collection('inventory')
        .doc(productId)
        .delete();

    List<Map<String, dynamic>> updatedProducts = List.from(state);
    updatedProducts.removeAt(index);
    emit(updatedProducts);
  }

  // Delete all products from Firestore and update state
  void deleteAllProducts() async {
    final batch = FirebaseFirestore.instance.batch();
    final querySnapshot =
        await FirebaseFirestore.instance.collection('inventory').get();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    emit([]);
  }

  Future<void> exportToExcel() async {
    try {
      // Create an Excel workbook
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Inventory';

      // Add headers
      sheet.getRangeByName('A1').setText('Barcode');
      sheet.getRangeByName('B1').setText('Quantity');
      sheet.getRangeByName('C1').setText('Expiration Date');
      sheet.getRangeByName('D1').setText('Warehouse');

      // Add data rows
      for (int i = 0; i < state.length; i++) {
        final product = state[i];
        sheet.getRangeByName('A${i + 2}').setText(product['barcode']);
        sheet
            .getRangeByName('B${i + 2}')
            .setNumber(product['quantity']?.toDouble() ?? 0.0);
        sheet.getRangeByName('C${i + 2}').setText(product['expirationDate']);
        sheet.getRangeByName('D${i + 2}').setText(product['warehouse']);
      }

      // Save the workbook to a file
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/inventory.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Convert the file path to an XFile
      final XFile xfile = XFile(filePath);

      // Share the file
      await Share.shareXFiles([xfile], text: 'Inventory exported to Excel.');

      print('Excel file exported and shared successfully.');
    } catch (e) {
      print('Error exporting or sharing Excel file: $e');
    }
  }
}
