import 'package:flutter/material.dart';

class ButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.cubicTo(size.width, size.height / 1.3, size.height / 1.3, size.height,
        size.width, size.height);
    path.cubicTo(0, size.height, 0, 0, size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(ButtonClipper oldClipper) => false;
}
