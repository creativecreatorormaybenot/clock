import 'dart:math';
import 'dart:ui' as ui;

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

  /// Returns a trimmed version of this path.
  ///
  /// Adapted from https://github.com/2d-inc/Flare-Flutter/blob/865e090c93a0d0ac92dac2b236054bef4b091d71/flare_flutter/lib/trim_path.dart.
  Path trimmed(double start, double end) {
    final result = Path();

    // Measure length of all the contours.
    var metrics = computeMetrics();
    var totalLength = 0.0;
    for (final metric in metrics) {
      totalLength += metric.length;
    }

    // Reset metrics from the start.
    metrics = computeMetrics();
    var trimStart = totalLength * start, trimStop = totalLength * end, offset = 0.0;

    final metricsIterator = metrics.iterator;
    metricsIterator.moveNext();
    if (trimStart > 0.0) {
      offset = _appendPathSegmentSequential(metricsIterator, result, offset, 0.0, trimStart);
    }
    if (trimStop < totalLength) {
      offset = _appendPathSegmentSequential(metricsIterator, result, offset, trimStop, totalLength);
    }

    return result;
  }
}

/// https://github.com/2d-inc/Flare-Flutter/blob/865e090c93a0d0ac92dac2b236054bef4b091d71/flare_flutter/lib/trim_path.dart#L5
double _appendPathSegmentSequential(Iterator<ui.PathMetric> metricsIterator, Path to, double offset, double start, double stop) {
  var nextOffset = offset;

  do {
    final metric = metricsIterator.current;
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
  } while (metricsIterator.moveNext());

  return offset;
}
