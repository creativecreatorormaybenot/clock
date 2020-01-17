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
class Tuple<T extends num> {
  final T first, second;

  const Tuple(this.first, this.second);

  Tuple<T> operator +(Tuple<T> other) => Tuple(first + other.first, second + other.second);

  Tuple<T> operator -(Tuple<T> other) => Tuple(first - other.first, second - other.second);

  Tuple<T> operator *(num other) => Tuple(first * other, second * other);
}
