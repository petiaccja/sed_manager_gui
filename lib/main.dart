import 'package:flutter/material.dart';
import 'interface/select_drive.dart';
import 'dart:ui';

void main() {
  runApp(const SEDManagerApp());
}

class SEDManagerApp extends StatelessWidget {
  const SEDManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEDManager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 22, 42, 109)),
        useMaterial3: true,
      ),
      home: SelectDrivePage(() {}),
    );
  }
}
