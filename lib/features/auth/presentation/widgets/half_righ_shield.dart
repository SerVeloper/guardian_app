import 'package:flutter/material.dart';

class HalfRightShield extends StatelessWidget {
  final double size;
  final Color color;

  const HalfRightShield({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.centerRight,
        widthFactor: 0.5,
        child: Icon(
          Icons.shield_outlined,
          size: size,
          color: color,
        ),
      ),
    );
  }
}