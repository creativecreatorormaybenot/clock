import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';

/// Always maps the value returned from [lerp] to a value between `0` and `2 * pi`.
/// This can be used when drawing rotated pieces in a canvas because angles wrap around every two pi.
class AngleTween extends Tween<double> {
  AngleTween({
    double begin,
    double end,
  }) : super(begin: begin, end: end);

  /// The modulo behavior in Dart surprised me a bit here (https://stackoverflow.com/q/59470362/6509751).
  @override
  double lerp(double t) => t % (2 * pi);

  /// Ensures that `t = 0` and `t = 1` are passed to [lerp] as well.
  @override
  double transform(double t) {
    double v;
    if (t == 0) {
      v = begin;
    } else if (t == 1) {
      v = end;
    } else {
      v = super.lerp(t);
    }

    return lerp(v);
  }
}

extension OffsetTween on Tween<Offset> {
  double get distance => (end - begin).distance;
}

/// Tuple holding two values.
///
/// This can be used for [Tween]s, e.g. when
/// trying to animate a start and end value
/// simultaneously.
///
/// I used a generic type extending [num] previously,
/// but when going back to `stable`, I saw some
/// very strange type errors that I was not able
/// to resolve.
/// I think it was really some logger issue that
/// was showing these errors over and over again
/// because they did not make any sense and were
/// not even matching the class name at some point.
class DoubleTuple {
  final double first, second;

  const DoubleTuple(this.first, this.second);

  DoubleTuple operator +(DoubleTuple other) => DoubleTuple(first + other.first, second + other.second);

  DoubleTuple operator -(DoubleTuple other) => DoubleTuple(first - other.first, second - other.second);

  DoubleTuple operator *(double other) => DoubleTuple(first * other, second * other);
}
