import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'login_page.dart';

void main() {
  DevicePreview.enable(); // otomatis off di release build
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A2A82)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}