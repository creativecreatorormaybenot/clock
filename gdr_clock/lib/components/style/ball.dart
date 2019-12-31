import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class Ball extends LeafRenderObjectWidget {
  final double radius;

  Ball({
    Key key,
    this.radius,
  }) : super(key: key);

  @override
  RenderBall createRenderObject(BuildContext context) {
    return RenderBall(
      radius: radius,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBall renderObject) {
    renderObject..radius = radius;
  }
}

class RenderBall extends RenderCompositionChild {
  RenderBall({
    double radius,
  })  : _radius = radius,
        super(ClockComponent.ball);

  double _radius;

  set radius(double radius) {
    if (_radius != radius) markNeedsLayout();

    _radius = radius;
  }

  @override
  void performLayout() {
    size = Size.fromRadius(_radius);
  }

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
          ..shader = const SweepGradient(
                  endAngle: pi / 2,
                  colors: [
                    Color(0xffd3d3ff),
                    Color(0xff9a9aff),
                  ],
                  tileMode: TileMode.mirror)
              .createShader(rect));

    canvas.restore();
  }
}
