import 'dart:math';

import 'package:flutter/animation.dart';

/// Curve describing the bouncing motion of the clock hands.
///
/// [ElasticOutCurve] already showed the overshoot beyond the destination position well,
/// however, the oscillation movement back to before the destination position was not pronounced enough.
/// Changing [ElasticOutCurve.period] to values greater than `0.4` will decrease how much the
/// curve oscillates as a whole, but I only wanted to decrease the magnitude of the first part
/// of the oscillation and increase the second to match real hand movement more closely,
/// hence, I created [HandBounceCurve].
///
/// I used this [slow motion capture of a watch](https://youtu.be/tyl7-gHRBX8?t=29) as a guide.
class HandBounceCurve extends Curve {
  const HandBounceCurve();

  @override
  double transformInternal(double t) {
    return troughTransform(elasticTransform(t));
  }

  double elasticTransform(double t) {
    final b = 12 / 27;
    return 1 + pow(2, -10 * t) * sin(((t - b / 4) * pi * 2) / b);
  }

  /// [Chris Drost helped me](https://math.stackexchange.com/a/3475134/569406) with this one.
  /// I have to say that I was mentally absent when reading through the solution for the first few times
  /// but figured it out eventually after coming back to it later. The result works fairly well.
  double troughTransform(double t) {
    return t * (1 - pow(e, pow(t, 12) * -5) * 4 / 9);
  }
}

/// Based on [Curves.decelerate].
/// I could have used [Curve.flipped], but that is not a `const` value.
class AccelerationCurve extends Curve {
  const AccelerationCurve();

  @override
  double transformInternal(double t) {
    return t * t;
  }
}
