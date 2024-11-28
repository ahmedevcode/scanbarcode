import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'; // For Workbook
// For file operations
import 'package:share_plus/share_plus.dart';

class ProductCubit extends Cubit<List<Map<String, dynamic>>> {
  ProductCubit() : super([]);

  /// Add a product to Firestore and update the state
  void addProduct(String barcode, int quantity, DateTime expirationDate,
      String warehouse) async {
    final product = {
      'barcode': barcode,
      'quantity': quantity,
      'currentDate': expirationDate.toIso8601String(),
      'warehouse': warehouse,
    };

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('inventory').add(product);
      emit([
        ...state,
        {'id': docRef.id, ...product}
      ]); // Update local state with Firestore ID
      if (kDebugMode) {
        print('Product added successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding product: $e');
      }
    }
  }

  /// Fetch products from Firestore and update the state
  void fetchProducts() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('inventory').get();
      List<Map<String, dynamic>> products = querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
      emit(products); // Update state with the latest data
      if (kDebugMode) {
        print('Products fetched successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching products: $e");
      }
    }
  }

  /// Delete a single product from Firestore and update the state
  void deleteProduct(String productId, int index) async {
    if (kDebugMode) {
      print('Deleting product with ID: $productId');
    }
    try {
      await FirebaseFirestore.instance
          .collection('inventory')
          .doc(productId)
          .delete();
      List<Map<String, dynamic>> updatedProducts = List.from(state);
      updatedProducts.removeAt(index);
      emit(updatedProducts); // Emit updated state
      if (kDebugMode) {
        print('Product deleted successfully.');
      }
      if (kDebugMode) {
        print('Deleting product with ID: $productId');
      } // Check this output
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting product: $e');
      }
    }
  }

  /// Delete all products from Firestore and clear the state
  void deleteAllProducts() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final querySnapshot =
          await FirebaseFirestore.instance.collection('inventory').get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      emit([]); // Clear the state after deletion
      if (kDebugMode) {
        print('All products deleted successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting all products: $e');
      }
    }
  }

  /// Export products to an Excel file and share it
  Future<void> exportToExcel() async {
    try {
      // Create an Excel workbook
      final Workbook workbook = Workbook();
      final Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Inventory';

      // Add headers
      sheet.getRangeByName('A1').setText('Barcode');
      sheet.getRangeByName('B1').setText('Quantity');
      sheet.getRangeByName('C1').setText('Current Date');
      sheet.getRangeByName('D1').setText('Warehouse');

      // Add product rows
      for (int i = 0; i < state.length; i++) {
        final product = state[i];
        sheet.getRangeByName('A${i + 2}').setText(product['barcode']);
        sheet
            .getRangeByName('B${i + 2}')
            .setNumber(product['quantity']?.toDouble() ?? 0.0);
        sheet.getRangeByName('C${i + 2}').setText(product['currentDate']);
        sheet.getRangeByName('D${i + 2}').setText(product['warehouse']);
      }

      // Save workbook to file
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/inventory.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Share file
      await Share.shareXFiles([XFile(filePath)],
          text: 'Inventory exported to Excel.');
      if (kDebugMode) {
        print('Excel file exported and shared successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting or sharing Excel file: $e');
      }
    }
  }
}
