import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scanbarcode/scan_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Scanbar());
}
