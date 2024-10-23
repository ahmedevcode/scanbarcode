import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/controller/product_cubit.dart';

class ProductScanningScreen extends StatefulWidget {
  @override
  _ProductScanningScreenState createState() => _ProductScanningScreenState();
}

class _ProductScanningScreenState extends State<ProductScanningScreen> {
  String _barcode = '';
  int _quantity = 1;
  DateTime _expirationDate = DateTime.now();
  String _warehouse = '';

  Future<void> _scanBarcode() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.BARCODE);
    if (barcode != "-1") {
      setState(() {
        _barcode = barcode;
      });
    }
  }

  Future<void> _pickExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _expirationDate = date;
      });
    }
  }

  void _addProduct() {
    if (_barcode.isNotEmpty && _warehouse.isNotEmpty) {
      context
          .read<ProductCubit>()
          .addProduct(_barcode, _quantity, _expirationDate, _warehouse);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product added successfully!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _scanBarcode,
              child: Text('Scan Barcode'),
            ),
            if (_barcode.isNotEmpty) Text('Scanned Barcode: $_barcode'),
            TextField(
              decoration: InputDecoration(labelText: 'Warehouse Name'),
              onChanged: (value) => _warehouse = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _quantity = int.tryParse(value) ?? 1,
            ),
            ElevatedButton(
              onPressed: _pickExpirationDate,
              child: Text('Pick Expiration Date'),
            ),
            if (_expirationDate != null)
              Text(
                  'Selected Expiration Date: ${DateFormat('yyyy-MM-dd').format(_expirationDate)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
