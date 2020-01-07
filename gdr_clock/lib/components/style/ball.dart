import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

const arrivalDuration = Duration(milliseconds: 920),
    departureDuration = Duration(milliseconds: 1242),
    arrivalCurve = AccelerateCurve(),
    departureCurve = Curves.decelerate,
    travelCurve = Curves.linear,
    bounceAwayDuration = Duration(milliseconds: 346),
    bounceBackDuration = Duration(milliseconds: 671),
    bounceAwayCurve = Curves.elasticOut,
    bounceBackCurve = Curves.elasticOut;

class Ball extends LeafRenderObjectWidget {
  final Animation<double> arrivalAnimation, departureAnimation;

  final Color primaryColor, secondaryColor;

  const Ball({
    Key key,
    @required this.arrivalAnimation,
    @required this.departureAnimation,
    @required this.primaryColor,
    @required this.secondaryColor,
  })  : assert(arrivalAnimation != null),
        assert(departureAnimation != null),
        assert(primaryColor != null),
        assert(secondaryColor != null),
        super(key: key);

  @override
  RenderBall createRenderObject(BuildContext context) {
    return RenderBall(
      arrivalAnimation: arrivalAnimation,
      departureAnimation: departureAnimation,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBall renderObject) {
    renderObject
      ..primaryColor = primaryColor
      ..secondaryColor = secondaryColor;
  }
}

class RenderBall extends RenderCompositionChild {
  final Animation<double> arrivalAnimation, departureAnimation;

  RenderBall({
    this.arrivalAnimation,
    this.departureAnimation,
    Color primaryColor,
    Color secondaryColor,
  })  : _primaryColor = primaryColor,
        _secondaryColor = secondaryColor,
        super(ClockComponent.ball);

  Color _primaryColor, _secondaryColor;

  set primaryColor(Color value) {
    assert(value != null);

    if (_primaryColor == value) {
      return;
    }

    _primaryColor = value;
    markNeedsPaint();
  }

  set secondaryColor(Color value) {
    assert(value != null);

    if (_secondaryColor == value) {
      return;
    }

    _secondaryColor = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    arrivalAnimation.addListener(markNeedsPaint);
    departureAnimation.addListener(markNeedsPaint);

    (compositionData as ClockChildrenParentData).hasSemanticsInformation = false;
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

  List<Color> get shaderColors => [_primaryColor, _secondaryColor];

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate to the center of the ball.
    canvas.translate(offset.dx, offset.dy);

    final rect = Offset.zero & Size.fromRadius(_radius),
        // Rotate the ball as if it rolled when it falls down and
        // flies back up.
        angle = 2 * pi * (1 - (arrivalAnimation.status == AnimationStatus.forward ? arrivalAnimation.value : departureAnimation.value));

    canvas.drawOval(
      rect,
      Paint()
        ..shader = kIsWeb
            // The kIsWeb section in here is irrelevant for the submission,
            // but I want to be able to host the clock face as a demo using
            // Flutter web and Flutter web does not currently support sweep gradients.
            ? ui.Gradient.radial(rect.center, rect.shortestSide / 2, shaderColors)
            : SweepGradient(
                startAngle: angle,
                endAngle: angle + pi / 2,
                colors: shaderColors,
                tileMode: TileMode.mirror,
              ).createShader(rect),
    );

    canvas.restore();
  }
}
