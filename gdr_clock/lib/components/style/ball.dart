import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class Ball extends LeafRenderObjectWidget {
  const Ball({
    Key key,
  }) : super(key: key);

  @override
  RenderBall createRenderObject(BuildContext context) {
    return RenderBall();
  }
}

class RenderBall extends RenderCompositionChild {
  RenderBall() : super(ClockComponent.ball);

  @override
  bool get sizedByParent => true;

  double _radius;

  @override
  void performResize() {
    _radius = constraints.biggest.height / 18;

    size = Size.fromRadius(_radius);
  }

  static const shaderColors = [
    Color(0xffd3d3ff),
    Color(0xff9a9aff),
  ];

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate to the center of the ball.
    canvas.translate(offset.dx, offset.dy);

    final rect = Offset.zero & Size.fromRadius(_radius);

    canvas.drawOval(
        rect,
        Paint()
          ..shader = kIsWeb
              // The kIsWeb section in here is irrelevant for the submission,
              // but I want to be able to host the clock face as a demo using
              // Flutter web and Flutter web does not currently support sweep gradients.
              ? ui.Gradient.radial(rect.center, rect.shortestSide / 2, shaderColors)
              : const SweepGradient(endAngle: pi * (kIsWeb ? 2 : 1 / 2), colors: shaderColors, tileMode: TileMode.clamp).createShader(rect));

    canvas.restore();
  }
}
