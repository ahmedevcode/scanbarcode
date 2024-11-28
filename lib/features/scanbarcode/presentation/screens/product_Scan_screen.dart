import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/controller/product_cubit.dart';

class ProductScanningScreen extends StatefulWidget {
  const ProductScanningScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductScanningScreenState createState() => _ProductScanningScreenState();
}

class _ProductScanningScreenState extends State<ProductScanningScreen> {
  String _barcode = '';
  int _quantity = 1;
  DateTime _expirationDate = DateTime.now();
  String _warehouse = '';

  // New scanning function using mobile_scanner
  Future<void> _scanBarcode() async {
    final MobileScannerController cameraController = MobileScannerController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scan Barcode'),
          content: SizedBox(
            height: 300.h,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                if (barcode.rawValue != null) {
                  setState(() {
                    _barcode = barcode.rawValue!;
                  });
                  Navigator.of(context)
                      .pop(); // Close the scanner once a barcode is detected
                }
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                cameraController.stop();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Product added successfully!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _scanBarcode,
              child: const Text('Scan Barcode'),
            ),
            if (_barcode.isNotEmpty) Text('Scanned Barcode: $_barcode'),
            TextField(
              decoration: const InputDecoration(labelText: 'Warehouse Name'),
              onChanged: (value) => _warehouse = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _quantity = int.tryParse(value) ?? 1,
            ),
            ElevatedButton(
              onPressed: _pickExpirationDate,
              child: const Text('Pick  Date'),
            ),
            Text(
                'Selected  Date: ${DateFormat('yyyy-MM-dd').format(_expirationDate)}'),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
