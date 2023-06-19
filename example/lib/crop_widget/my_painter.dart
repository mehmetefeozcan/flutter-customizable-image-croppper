import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MyCstmPainter extends CustomPainter {
  final List linePoints;
  final Color lineColor;
  final double? lineWidth;

  MyCstmPainter({
    required this.linePoints,
    required this.lineColor,
    this.lineWidth = 1,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    var paint = Paint();
    paint.color = lineColor;
    paint.strokeWidth = lineWidth!;

    canvas.drawLine(linePoints[0][0], linePoints[0][1], paint);
    canvas.drawLine(linePoints[1][0], linePoints[1][1], paint);
    canvas.drawLine(linePoints[2][0], linePoints[2][1], paint);
    canvas.drawLine(linePoints[3][0], linePoints[3][1], paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
