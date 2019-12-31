import 'dart:math';

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
//          ..shader = const SweepGradient(
//                  endAngle: pi / 2,
//                  colors: [
//                    Color(0xffd3d3ff),
//                    Color(0xff9a9aff),
//                  ],
//                  tileMode: TileMode.mirror) todo unsupported in web
//              .createShader(rect)
    );

    canvas.restore();
  }
}
