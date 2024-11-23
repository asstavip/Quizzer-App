import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  final String type;

  const CustomSnackBar({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      backgroundColor: type == 'success' ? Colors.green : Colors.red,
      content: Row(
        children: [
          Icon(type == 'success' ? Icons.check : Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Text(type == 'success' ? 'PDF successfully read! ' : 'Error', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

