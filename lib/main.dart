import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/controller/product_cubit.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/screens/product_Scan_screen.dart';
import 'package:scanbarcode/features/scanbarcode/presentation/screens/widgets/custom_invetory_screen.dart';
import 'package:scanbarcode/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventory App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventory Management")),
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
              child: Text("Scan Product"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventoryScreen()),
              ),
              child: Text("View Inventory"),
            ),
          ],
        ),
      ),
    );
  }
}
