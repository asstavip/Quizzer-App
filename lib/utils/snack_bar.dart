import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  final String type;

  CustomSnackBar({required this.type});

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      backgroundColor: type == 'success' ? Colors.green : Colors.red,
      content: Row(
        children: [
          Icon(type == 'success' ? Icons.check : Icons.error, color: Colors.white),
          SizedBox(width: 8),
          Text(type == 'success' ? 'PDF successfully read! ' : 'Error', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

