import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

const arrivalDuration = Duration(milliseconds: 920), departureDuration = Duration(milliseconds: 1242), arrivalCurve = AccelerateCurve(), departureCurve = Curves.decelerate;

/// Based on [Curves.decelerate].
/// I could have used [Curve.flipped], but that is not a `const` value.
class AccelerateCurve extends Curve {
  const AccelerateCurve();

  @override
  double transformInternal(double t) {
    return t * t;
  }
}

class Ball extends LeafRenderObjectWidget {
  final Animation<double> arrivalAnimation, departureAnimation;

  const Ball({
    Key key,
    @required this.arrivalAnimation,
    @required this.departureAnimation,
  })  : assert(arrivalAnimation != null),
        assert(departureAnimation != null),
        super(key: key);

  @override
  RenderBall createRenderObject(BuildContext context) {
    return RenderBall(
      arrivalAnimation: arrivalAnimation,
      departureAnimation: departureAnimation,
    );
  }
}

class RenderBall extends RenderCompositionChild {
  final Animation<double> arrivalAnimation, departureAnimation;

  RenderBall({
    this.arrivalAnimation,
    this.departureAnimation,
  }) : super(ClockComponent.ball);

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    arrivalAnimation.addListener(markNeedsPaint);
    departureAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    arrivalAnimation.removeListener(markNeedsPaint);
    departureAnimation.removeListener(markNeedsPaint);

    super.detach();
  }

  @override
  bool get sizedByParent => true;

  double _radius;

  @override
  void performResize() {
    _radius = constraints.biggest.height / 21;

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
            : const SweepGradient(
                endAngle: pi / 2,
                colors: shaderColors,
                tileMode: TileMode.mirror,
              ).createShader(rect),
    );

    canvas.restore();
  }
}
