import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final Widget child;
  final Color? color;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;

  FlatButton({
    required this.child,
    required this.onPressed,
    this.color,
    this.padding = const EdgeInsets.all(8.0),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(4.0),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
