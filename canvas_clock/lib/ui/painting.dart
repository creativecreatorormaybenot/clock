import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

extension ExtendedCanvas on Canvas {
  static const petals = 14, petalWeightDivisor = 2.0;

  /// Draws a petals design based on a full [radius], that is not the radius of the petals.
  ///
  /// Regarding the naming scheme: I have decided to name everything that is on [Canvas]
  /// (following existing methods) or takes a canvas - preferably as its first - parameter
  /// `drawX` and anything that might take a [PaintingContext] `paintX`.
  void drawPetals(Color color, Color highlightColor, double radius) {
    final petalShader = RadialGradient(
      colors: [
        highlightColor,
        color,
      ],
      stops: const [
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
      _drawPetal(paint, radius / 4.2);

      restore();
    }
  }

  void _drawPetal(Paint paint, double radius) {
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

  /// Draws a lid for hands on a dial or clock, i.e. a circular piece with a shadow.
  void drawLid(Color color, Color highlightColor, Color shadowColor, double radius, double shadowElevation) {
    final rect = Rect.fromCircle(
      center: Offset.zero,
      radius: radius,
    ),
        shader = ui.Gradient.radial(
      Offset.zero,
      rect.shortestSide / 2,
      [
        highlightColor,
        color,
      ],
    ),
        paint = Paint()
          ..shader = shader
          ..style = PaintingStyle.fill,
        path = Path()..addOval(rect);

    drawShadow(path, shadowColor, shadowElevation, false);
    drawPath(path, paint);
  }
}

extension ExtendedPath on Path {
  /// Draws a half circle to the given position.
  ///
  /// Instead of using [conicTo] for conic curves
  /// for drawing round caps, this has better syntax than
  /// [arcToPoint] for where it is used and an accurate half circle,
  /// which [conicTo] does not seem to have.
  ///
  /// This is supposed to be an alternative to using
  /// [conicTo] with a weight of `1 / 2` because it
  /// will draw an actual half circle and has
  /// syntax that resembles [lineTo] and others more
  /// than [arcToPoint] does.
  void halfCircleTo(double x, double y, [bool clockwise = true]) {
    arcToPoint(Offset(x, y), radius: const Radius.circular(1), clockwise: clockwise);
  }

  void leafTipTo(double sx, double sy, double ex, double ey, double c, double f) {
    quadraticBezierTo(
      -c,
      sy - (sy - ey) / f,
      ex,
      ey,
    );
    quadraticBezierTo(
      c,
      sy - (sy - ey) / f,
      ex - sx,
      sy,
    );
  }

  /// Returns a trimmed version of this path.
  ///
  /// Adapted from https://github.com/2d-inc/Flare-Flutter/blob/eb4a7d77a9fe453f5907eb1c720a39ac9fe80a0c/flare_flutter/lib/trim_path.dart
  ///
  /// Unsupported in Flutter web, see https://github.com/flutter/flutter/issues/48386.
  Path trimmed(double start, double end, [bool complement = false]) {
    if (kIsWeb) return Path.from(this);

    final result = Path();

    var metrics = computeMetrics(), totalLength = 0.0;
    for (final metric in metrics) {
      totalLength += metric.length;
    }

    metrics = computeMetrics();
    var trimStart = totalLength * start, trimStop = totalLength * end, offset = 0.0;

    if (complement) {
      if (trimStart > 0.0) {
        offset = _appendPathSegment(metrics, this, result, offset, 0.0, trimStart);
      }
      if (trimStop < totalLength) {
        offset = _appendPathSegment(metrics, this, result, offset, trimStop, totalLength);
      }
    } else {
      if (trimStart < trimStop) {
        offset = _appendPathSegment(metrics, this, result, offset, trimStart, trimStop);
      }
    }

    return result;
  }
}

/// https://github.com/2d-inc/Flare-Flutter/blob/eb4a7d77a9fe453f5907eb1c720a39ac9fe80a0c/flare_flutter/lib/trim_path.dart#L3
double _appendPathSegment(ui.PathMetrics metrics, Path from, Path to, double offset, double start, double stop) {
  var nextOffset = offset;

  for (final metric in metrics) {
    nextOffset = offset + metric.length;
    if (start < nextOffset) {
      final extracted = metric.extractPath(start - offset, stop - offset);
      if (extracted != null) {
        to.addPath(extracted, Offset.zero);
      }
      if (stop < nextOffset) {
        break;
      }
    }
    offset = nextOffset;
  }

  return offset;
}
