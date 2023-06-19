import 'package:flutter/material.dart';

class MyImageClipper extends CustomClipper<Path> {
  final List<Offset> points;

  MyImageClipper({required this.points});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    path.lineTo(points[1].dx, points[1].dy);
    path.lineTo(points[2].dx, points[2].dy);
    path.lineTo(points[3].dx, points[3].dy);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
