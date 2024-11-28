import 'package:flutter/material.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/screens/product_Scan_screen.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/screens/widgets/custom_invetory_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory Management")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductScanningScreen()),
              ),
              child: const Text("Scan Product"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventoryScreen()),
              ),
              child: const Text("View Inventory"),
            ),
          ],
        ),
      ),
    );
  }
}
