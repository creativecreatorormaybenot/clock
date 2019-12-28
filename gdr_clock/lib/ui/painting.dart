import 'dart:math';
import 'dart:ui';

extension ExtendedCanvas on Canvas {
  void paintPetals(Paint paint, double radius, double weightDivisor, int number) {
    for (var i = 0; i < number; i++) {
      save();

      rotate(2 * pi / number * i);
      _paintPetal(paint, radius, weightDivisor);

      restore();
    }
  }

  void _paintPetal(Paint paint, double radius, double weightDivisor) {
    final path = Path()
      ..moveTo(0, 0)
      // Could use conicTo instead and pass a weight there, but
      // it works better for me doing it this way.
      ..quadraticBezierTo(
        -radius / weightDivisor,
        radius / 2,
        0,
        radius,
      )
      ..quadraticBezierTo(
        radius / weightDivisor,
        radius / 2,
        0,
        0,
      )
      ..close();

    drawPath(path, paint);
  }
}
