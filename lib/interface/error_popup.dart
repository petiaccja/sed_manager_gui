import 'package:flutter/material.dart';
import 'dart:ui';

class ErrorPopupPage extends StatelessWidget {
  const ErrorPopupPage(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        elevation: 10,
        title: const Text("Error!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
