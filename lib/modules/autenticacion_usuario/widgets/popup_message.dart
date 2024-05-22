// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class PopupMessage extends StatelessWidget {

  final String title;
  final String description;

  const PopupMessage({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      backgroundColor: Colors.grey.shade900,
      content: Text(description, style: const TextStyle(color: Colors.grey)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar', style: TextStyle(color: Colors.blueAccent)))
      ],
    );
  }
}