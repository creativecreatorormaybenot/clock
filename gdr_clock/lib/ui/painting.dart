import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';

extension ExtendedCanvas on Canvas {
  static const petalColor = Color(0xffbab33c), petals = 14, petalWeightDivisor = 2.0;

  /// Paints a petals design based on a full [radius], that is not the radius of the petals.
  ///
  /// Regarding the naming scheme: I have decided to name everything that is on [Canvas]
  /// (following existing methods) or takes a canvas - preferably as its first - parameter
  /// `drawX` and anything that might take a [PaintingContext] `paintX`.
  void drawPetals(double radius) {
    final petalShader = const RadialGradient(
      colors: [
        Color(0xffffffff),
        petalColor,
      ],
      stops: [
        0,
        .3,
      ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
        paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius / 107
          ..shader = petalShader;

    for (var i = 0; i < petals; i++) {
      save();

      rotate(2 * pi / petals * i);
      _drawPetals(paint, radius / 4.2);

      restore();
    }
  }

  void _drawPetals(Paint paint, double radius) {
    final path = Path()
      ..moveTo(0, 0)
      // Could use conicTo instead and pass a weight there, but
      // it works better for me doing it this way.
      ..quadraticBezierTo(
        -radius / petalWeightDivisor,
        radius / 2,
        0,
        radius,
      )
      ..quadraticBezierTo(
        radius / petalWeightDivisor,
        radius / 2,
        0,
        0,
      )
      ..close();

    drawPath(path, paint);
  }
}
