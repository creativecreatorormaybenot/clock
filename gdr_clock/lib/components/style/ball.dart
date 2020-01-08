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
  final Color primaryColor, secondaryColor;

  const Ball({
    Key key,
    @required this.primaryColor,
    @required this.secondaryColor,
  })  : assert(primaryColor != null),
        assert(secondaryColor != null),
        super(key: key);

  @override
  RenderBall createRenderObject(BuildContext context) {
    return RenderBall(
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

enum BallMovementStage {
  travel,
  arrival,
  departure,
}

class BallParentData extends ClockChildrenParentData {
  BallMovementStage stage;

  double movementProgress;

  /// The distance the ball needs to travel for
  /// the current [stage].
  double movementDistance;
}

/// Renders a ball moving about the scene.
///
/// The movement of the ball is separated into three stages:
///
///  1. Travel, which brings the ball from the end point to the start point.
///  1. Arrival, which brings the ball from the start point to its destination.
///  1. Departure, which brings the ball away from the destination to the end point.
///
/// See also: [BallMovementStage]
///
/// The ball also rotates to resemble rolling and this rotation is calculated
/// by taking the circumference of the circle, the distance of the current stage, and
/// the progress of the current movement.
class RenderBall extends RenderCompositionChild<ClockComponent, BallParentData> {
  RenderBall({
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

    compositionData.hasSemanticsInformation = false;
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
    // Translate to the top left of the ball.
    canvas.translate(offset.dx, offset.dy);

    // This is the circumference of the ball. Basically,
    // it is its length when unwrapping its circle.
    final ballLength = _radius * 2 * pi,
        // Controls which direction the ball rotates in.
        direction = compositionData.stage == BallMovementStage.travel ? 1 : -1;

    final rect = Offset.zero & Size.fromRadius(_radius),
        // Rotate the ball as if it rolled when it falls down and
        // flies back up.
        angle = 2 * pi * (compositionData.movementDistance / ballLength) * compositionData.movementProgress * direction;

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

    // Draw small dot onto the ball.
    // The point is to indicate the rotation (rolling)
    // even when the radial shader has to be used because
    // of lacking Flutter web support.
    canvas.drawOval(
      Rect.fromCircle(
        center:
            // Translate to the center of the ball first
            Offset(size.width / 2, size.height / 2) +
                // Position of the dot relative to the center of the ball
                Offset.fromDirection(pi / 2 + angle, _radius * 2 / 3),
        radius: _radius / 9,
      ),
      Paint()..color = _primaryColor,
    );

    canvas.restore();
  }
}
