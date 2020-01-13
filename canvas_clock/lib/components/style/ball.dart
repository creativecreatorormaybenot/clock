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

  final Color primaryColor, secondaryColor, dotsIdleColor, dotsPrimedColor, dotsDisengagedColor;

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
  })  : assert(travelAnimation != null),
        assert(arrivalAnimation != null),
        assert(departureAnimation != null),
        assert(trips != null),
        assert(primaryColor != null),
        assert(secondaryColor != null),
        assert(dotsIdleColor != null),
        assert(dotsPrimedColor != null),
        assert(dotsDisengagedColor != null),
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
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBall renderObject) {
    renderObject
      ..primaryColor = primaryColor
      ..secondaryColor = secondaryColor
      ..dotsIdleColor = dotsIdleColor
      ..dotsPrimedColor = dotsPrimedColor
      ..dotsIdleColor = dotsIdleColor;
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
  })  : _primaryColor = primaryColor,
        _secondaryColor = secondaryColor,
        _dotsIdleColor = dotsIdleColor,
        _dotsPrimedColor = dotsPrimedColor,
        _dotsDisengagedColor = dotsDisengagedColor,
        super(ClockComponent.ball);

  Color _primaryColor, _secondaryColor, _dotsIdleColor, _dotsPrimedColor, _dotsDisengagedColor;

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

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData.hasSemanticsInformation = false;

    travelAnimation.addListener(markNeedsLayout);
    arrivalAnimation.addListener(markNeedsLayout);
    departureAnimation.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    travelAnimation.removeListener(markNeedsLayout);
    arrivalAnimation.removeListener(markNeedsLayout);
    departureAnimation.removeListener(markNeedsLayout);

    super.detach();
  }

  @override
  bool get sizedByParent => false;

  double _radius, _totalDistance, _distanceTraveled;

  BallTripStage stage;

  @override
  void performLayout() {
    size = constraints.biggest;

    _radius = size.height / 2;

    final ballArrivalTween = Tween(
      begin: compositionData.startPosition,
      end: compositionData.destination,
    ),
        ballDepartureTween = Tween(
      begin: compositionData.destination,
      end: compositionData.endPosition,
    ),
        ballTravelTween = Tween(
      begin: ballDepartureTween.end,
      end: ballArrivalTween.begin,
    );

    final travelDistance = ballTravelTween.distance,
        // Negative as the ball rolls backwards along this path.
        arrivalDistance = -ballArrivalTween.distance,
        departureDistance = -ballDepartureTween.distance;

    _totalDistance = travelDistance + arrivalDistance + departureDistance;

    if (departureAnimation.status == AnimationStatus.forward) {
      compositionData..offset = ballDepartureTween.evaluate(departureAnimation);

      _distanceTraveled = travelDistance + arrivalDistance + departureDistance * departureAnimation.value;

      stage = BallTripStage.departure;
    } else if (travelAnimation.status == AnimationStatus.forward) {
      compositionData..offset = ballTravelTween.evaluate(travelAnimation);

      _distanceTraveled = travelDistance * travelAnimation.value;

      stage = BallTripStage.travel;
    } else {
      compositionData..offset = ballArrivalTween.evaluate(arrivalAnimation);

      _distanceTraveled = travelDistance + arrivalDistance * arrivalAnimation.value;

      stage = BallTripStage.arrival;
    }

    // Draw the ball about the point, not at the point.
    compositionData.offset -= size.offset / 2;
  }

  List<Color> get shaderColors => [_primaryColor, _secondaryColor];

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate to the center of the ball.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

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
    final progress = (_distanceTraveled +
            // After every trip there will probably be some additional
            // distance that is not evenly divisible by the circumference,
            // which would cause the rotation to visually reset if
            // not accounted for.
            (_totalDistance % ballLength) * trips.count)
        // The ball needs to rotate once for every circumference
        // on the track.
        /
        ballLength;

    canvas.rotate(2 * pi * progress);

    canvas.drawOval(
      rect,
      Paint()
        ..shader = kIsWeb
            // The kIsWeb section in here is irrelevant for the submission,
            // but I want to be able to host the clock face as a demo using
            // Flutter web and Flutter web does not currently support sweep gradients.
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
