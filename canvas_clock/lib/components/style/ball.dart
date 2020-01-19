import 'dart:math';
import 'dart:ui' as ui;

import 'package:canvas_clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const arrivalDuration = Duration(milliseconds: 920),
    departureDuration = Duration(milliseconds: 1242),
    arrivalCurve = AccelerationCurve(),
    departureCurve = Curves.decelerate,
    travelCurve = AccelerationCurve(),
    bounceAwayDuration = Duration(milliseconds: 626),
    bounceBackDuration = Duration(milliseconds: 547),
    bounceAwayCurve = ElasticOutCurve(.67),
    bounceBackCurve = Curves.bounceOut;

class Ball extends LeafRenderObjectWidget {
  final Animation<double> travelAnimation, arrivalAnimation, departureAnimation;

  final BallTrips trips;

  final Color primaryColor, secondaryColor, dotsIdleColor, dotsPrimedColor, dotsDisengagedColor, shadowColor;

  const Ball({
    Key key,
    @required this.travelAnimation,
    @required this.arrivalAnimation,
    @required this.departureAnimation,
    @required this.trips,
    @required this.primaryColor,
    @required this.secondaryColor,
    @required this.dotsIdleColor,
    @required this.dotsPrimedColor,
    @required this.dotsDisengagedColor,
    @required this.shadowColor,
  })  : assert(travelAnimation != null),
        assert(arrivalAnimation != null),
        assert(departureAnimation != null),
        assert(trips != null),
        assert(primaryColor != null),
        assert(secondaryColor != null),
        assert(dotsIdleColor != null),
        assert(dotsPrimedColor != null),
        assert(dotsDisengagedColor != null),
        assert(shadowColor != null),
        super(key: key);

  @override
  RenderBall createRenderObject(BuildContext context) {
    return RenderBall(
      travelAnimation: travelAnimation,
      arrivalAnimation: arrivalAnimation,
      departureAnimation: departureAnimation,
      trips: trips,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      dotsIdleColor: dotsIdleColor,
      dotsPrimedColor: dotsPrimedColor,
      dotsDisengagedColor: dotsDisengagedColor,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBall renderObject) {
    renderObject
      ..primaryColor = primaryColor
      ..secondaryColor = secondaryColor
      ..dotsIdleColor = dotsIdleColor
      ..dotsPrimedColor = dotsPrimedColor
      ..dotsIdleColor = dotsIdleColor
      ..shadowColor = shadowColor;
  }
}

/// For information on what this is see [RenderBall].
enum BallTripStage {
  travel,
  arrival,
  departure,
}

/// A way to count the ball's trips while being able to
/// pass a pointer to the count around.
///
/// This is needed to account for the fact that the ball does not
/// rotate an integer amount of full rotations while rolling
/// along the track.
///
/// A [ValueNotifier] would also do the job, but I do not want
/// to notify. Hence, this is the simpler option.
class BallTrips {
  BallTrips([this.count = 0]);

  double count;
}

class BallParentData extends ClockChildrenParentData {
  Offset startPosition, endPosition, destination;

  /// Declares the radius that the circular ball should use.
  ///
  /// See [RenderBall.isRepaintBoundary] for why it is necessary
  /// to send this instead of sizing the ball to it.
  double radius;
}

/// Renders a ball moving about the scene.
///
/// The movement of the ball is separated into three stages:
///
///  1. Travel, which brings the ball from the end point to the start point.
///  1. Arrival, which brings the ball from the start point to its destination.
///  1. Departure, which brings the ball away from the destination to the end point.
///
/// The ball also rotates to resemble rolling and this rotation is calculated
/// by taking the circumference of the circle, the distance of the current stage, and
/// the progress of the current movement.
class RenderBall extends RenderCompositionChild<ClockComponent, BallParentData> {
  final Animation<double> travelAnimation, arrivalAnimation, departureAnimation;

  final BallTrips trips;

  RenderBall({
    this.travelAnimation,
    this.arrivalAnimation,
    this.departureAnimation,
    this.trips,
    Color primaryColor,
    Color secondaryColor,
    Color dotsIdleColor,
    Color dotsPrimedColor,
    Color dotsDisengagedColor,
    Color shadowColor,
  })  : _primaryColor = primaryColor,
        _secondaryColor = secondaryColor,
        _dotsIdleColor = dotsIdleColor,
        _dotsPrimedColor = dotsPrimedColor,
        _dotsDisengagedColor = dotsDisengagedColor,
        _shadowColor = shadowColor,
        super(ClockComponent.ball);

  Color _primaryColor, _secondaryColor, _dotsIdleColor, _dotsPrimedColor, _dotsDisengagedColor, _shadowColor;

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

  set dotsIdleColor(Color value) {
    assert(value != null);

    if (_dotsIdleColor == value) {
      return;
    }

    _dotsIdleColor = value;
    markNeedsPaint();
  }

  set dotsPrimedColor(Color value) {
    assert(value != null);

    if (_dotsPrimedColor == value) {
      return;
    }

    _dotsPrimedColor = value;
    markNeedsPaint();
  }

  set dotsDisengagedColor(Color value) {
    assert(value != null);

    if (_dotsDisengagedColor == value) {
      return;
    }

    _dotsDisengagedColor = value;
    markNeedsPaint();
  }

  set shadowColor(Color value) {
    assert(value != null);

    if (_shadowColor == value) {
      return;
    }

    _shadowColor = value;
    markNeedsPaint();
  }

  /// Ensures that the constant repaints from the ball
  /// do not cause the whole composition to repaint.
  ///
  /// It would be possible layout the ball with a box
  /// enclosing just its radius and calling [markNeedsLayout]
  /// to update its position instead.
  /// I did it like this before, but I do not
  /// want the ball causing the whole clock face to
  /// repaint - same goes for the analog clock.
  /// The reason this would happen is that a repaint
  /// boundary is not a relayout boundary and thus
  /// [markNeedsLayout] will also mark the parent as dirty.
  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData.hasSemanticsInformation = false;

    travelAnimation.addListener(markNeedsPaint);
    arrivalAnimation.addListener(markNeedsPaint);
    departureAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    travelAnimation.removeListener(markNeedsPaint);
    arrivalAnimation.removeListener(markNeedsPaint);
    departureAnimation.removeListener(markNeedsPaint);

    super.detach();
  }

  @override
  bool get sizedByParent => false;

  double _radius, _totalDistance;

  Tween<Offset> _travelTween, _arrivalTween, _departureTween;

  double _travelDistance, _arrivalDistance, _departureDistance;

  BallTripStage stage;

  @override
  void performLayout() {
    size = constraints.biggest;

    // The data passed only updates in ClockComposition.performLayout.
    _radius = compositionData.radius;

    _travelTween = Tween(
      begin: compositionData.endPosition,
      end: compositionData.startPosition,
    );
    _arrivalTween = Tween(
      begin: compositionData.startPosition,
      end: compositionData.destination,
    );
    _departureTween = Tween(
      begin: compositionData.destination,
      end: compositionData.endPosition,
    );

    _travelDistance = _travelTween.distance;
    // Negative as the ball rolls backwards along this path.
    _arrivalDistance = -_arrivalTween.distance;
    _departureDistance = -_departureTween.distance;

    _totalDistance = _travelDistance + _arrivalDistance + _departureDistance;
  }

  List<Color> get shaderColors => [_primaryColor, _secondaryColor];

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();

    var translation = offset;
    double distanceTraveled;

    if (departureAnimation.status == AnimationStatus.forward) {
      translation += _departureTween.evaluate(departureAnimation);

      distanceTraveled = _travelDistance + _arrivalDistance + _departureDistance * departureAnimation.value;

      stage = BallTripStage.departure;
    } else if (travelAnimation.status == AnimationStatus.forward) {
      translation += _travelTween.evaluate(travelAnimation);

      distanceTraveled = _travelDistance * travelAnimation.value;

      stage = BallTripStage.travel;
    } else {
      translation += _arrivalTween.evaluate(arrivalAnimation);

      distanceTraveled = _travelDistance + _arrivalDistance * arrivalAnimation.value;

      stage = BallTripStage.arrival;
    }

    // Translate to the center of the ball.
    canvas.translate(translation.dx, translation.dy);

    // This is the circumference of the ball. Basically,
    // it is its length when unwrapping its circle.
    final ballLength = _radius * 2 * pi;

    final rect = Rect.fromCircle(center: Offset.zero, radius: _radius);

    // Rotate the ball as if it rolled along the slides.
    // This value can be greater than 1, but I imagine that
    // leaving that is cheaper (regarding performance) than
    // using modulo.
    // It is fine because the Canvas.rotate also takes any multiples
    // of the rotation value and accepts it.
    final progress = (distanceTraveled +
                // After every trip there will probably be some additional
                // distance that is not evenly divisible by the circumference,
                // which would cause the rotation to visually reset if
                // not accounted for.
                (_totalDistance % ballLength) * trips.count)
            // The ball needs to rotate once for every circumference
            // on the track.
            /
            ballLength,
        path = Path()..addOval(rect);

    canvas.drawShadow(path, _shadowColor, _radius / 5, false);

    canvas.rotate(2 * pi * progress);
    canvas.drawPath(
      path,
      Paint()
        ..shader = kIsWeb
            // The kIsWeb section in here is irrelevant for the submission,
            // but I want to be able to host the clock face as a demo using
            // Flutter web and Flutter web does not currently support sweep gradients.
            // See https://github.com/flutter/flutter/issues/41389.
            ? ui.Gradient.radial(rect.center, rect.shortestSide / 2, shaderColors)
            : SweepGradient(
                startAngle: 0,
                endAngle: pi / 2,
                colors: shaderColors,
                tileMode: TileMode.mirror,
              ).createShader(rect),
    );

    _drawDots(canvas);

    canvas.restore();
  }

  /// Draws small dots on two sides
  /// of the ball.
  ///
  /// See [_drawDot].
  void _drawDots(Canvas canvas) {
    _drawDot(canvas, 0);
    _drawDot(canvas, pi);
  }

  Color get dotColor {
    switch (stage) {
      case BallTripStage.travel:
        return _dotsIdleColor;
      case BallTripStage.arrival:
        return _dotsPrimedColor;
      case BallTripStage.departure:
        return _dotsDisengagedColor;
    }
    throw ArgumentError.value(stage);
  }

  /// Draw small dot onto the ball.
  /// The point is to indicate the rotation (rolling)
  /// even when the radial shader has to be used because
  /// of lacking Flutter web support.
  void _drawDot(Canvas canvas, double angle) {
    canvas.save();

    canvas.rotate(angle);
    canvas.drawOval(
        Rect.fromCircle(
          center: Offset(0, _radius * 5 / 7),
          radius: _radius / 9,
        ),
        Paint()..color = dotColor);

    canvas.restore();
  }
}
