import 'dart:ui' as ui;

import 'package:canvas_clock/clock.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Slide extends LeafRenderObjectWidget {
  final Animation<double> ballTravelAnimation, ballArrivalAnimation, ballDepartureAnimation;

  final Color primaryColor, secondaryColor, shadowColor;

  Slide({
    Key key,
    @required this.ballTravelAnimation,
    @required this.ballArrivalAnimation,
    @required this.ballDepartureAnimation,
    @required this.primaryColor,
    @required this.secondaryColor,
    @required this.shadowColor,
  })  : assert(ballTravelAnimation != null),
        assert(ballArrivalAnimation != null),
        assert(ballDepartureAnimation != null),
        assert(primaryColor != null),
        assert(shadowColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSlide(
      ballTravelAnimation: ballTravelAnimation,
      ballArrivalAnimation: ballArrivalAnimation,
      ballDepartureAnimation: ballDepartureAnimation,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSlide renderObject) {
    renderObject
      ..primaryColor = primaryColor
      ..secondaryColor = secondaryColor
      ..shadowColor = shadowColor;
  }
}

class SlideParentData extends ClockChildrenParentData {
  /// Positions relative to the top left of the render box.
  Offset start, end, destination;

  double ballRadius;
}

class RenderSlide extends RenderCompositionChild<ClockComponent, SlideParentData> {
  final Animation<double> ballTravelAnimation, ballArrivalAnimation, ballDepartureAnimation;

  RenderSlide({
    this.ballTravelAnimation,
    this.ballArrivalAnimation,
    this.ballDepartureAnimation,
    Color primaryColor,
    Color secondaryColor,
    Color shadowColor,
  })  : _primaryColor = primaryColor,
        _secondaryColor = secondaryColor,
        _shadowColor = shadowColor,
        super(ClockComponent.slide);

  Color _primaryColor, _secondaryColor, _shadowColor;

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

  set shadowColor(Color value) {
    assert(value != null);

    if (_shadowColor == value) {
      return;
    }

    _shadowColor = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData.hasSemanticsInformation = false;

    ballTravelAnimation.addListener(updatePadding);
    ballArrivalAnimation.addListener(updatePadding);
    ballDepartureAnimation.addListener(updatePadding);
  }

  @override
  void detach() {
    ballTravelAnimation.removeListener(updatePadding);
    ballArrivalAnimation.removeListener(updatePadding);
    ballDepartureAnimation.removeListener(updatePadding);

    super.detach();
  }

  Line2d startLine, endLine, travelLine;

  /// The stroke width is drawn out equally in both directions from
  /// the 0 width line and thus, the lines need to be shifted a bit more
  /// if they should only touch the ball instead of overlapping.
  double strokeWidth;

  TweenSequence<double> leftTravelSequence, rightTravelSequence, arrivalSequence, departureSequence;

  @override
  void performResize() {
    final start = compositionData.start, end = compositionData.end, destination = compositionData.destination;

    // Need to know where the start line is located in order to
    // properly add padding to account for the ball's size.
    final startLeft = start.dx < end.dx;

    startLine = Line2d(start: start, end: destination)
      ..padStartEnd(
        1.85,
        .99,
      );
    endLine = Line2d(start: end, end: destination)
      ..padStartEnd(
        1.6,
        .58,
      );
    travelLine = Line2d(start: end, end: start);

    final ballRadius = compositionData.ballRadius, travelLength = travelLine.length, ballLengthFraction = ballRadius * 5 / travelLength, departureBallLengthFraction = ballLengthFraction * 1.12;

    strokeWidth = constraints.biggest.shortestSide / 52;

    final shiftFactor = 1 + strokeWidth / 2 / ballRadius;

    // The start line should touch the ball on its side.
    // The same also goes for the end line, which is
    // why startLeft is required.
    startLine.shift(startLine.normal.offset * ballRadius * (startLeft ? shiftFactor : -shiftFactor));
    endLine.shift(endLine.normal.offset * ballRadius * (startLeft ? -shiftFactor : shiftFactor));

    travelLine.pad(1.02);

    travelLine
        // The line should touch the ball's bottom.
        .shift(travelLine.normal.offset * ballRadius * shiftFactor);

    leftTravelSequence = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1 - departureBallLengthFraction,
          end: 1,
        ).chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn)),
        weight: ballRadius / 28,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: travelLength,
      ),
    ]);
    rightTravelSequence = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: travelLength,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1 - ballLengthFraction,
        ).chain(CurveTween(curve: const AccelerationCurve())),
        weight: ballRadius / 4,
      ),
    ]);
    arrivalSequence = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween<double>(1 - ballLengthFraction),
        weight: ballRadius * 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1 - ballLengthFraction,
          end: 1,
        ).chain(CurveTween(curve: const AccelerationCurve())),
        weight: startLine.length,
      ),
    ]);
    departureSequence = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1 - departureBallLengthFraction,
        ).chain(CurveTween(curve: Curves.decelerate)),
        weight: endLine.length,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1 - departureBallLengthFraction),
        weight: ballRadius * 15,
      ),
    ]);

    // This assumes that the padded travel line will not exceed these bounds.
    final rect = Rect.fromPoints(travelLine.start, travelLine.end).expandToInclude(Rect.fromPoints(startLine.start, startLine.end)).expandToInclude(Rect.fromPoints(endLine.start, endLine.end));

    compositionData.offset = rect.topLeft;
    size = rect.size;

    updatePadding();
  }

  Line2d paddedTravelLine;

  void updatePadding() {
    if (!hasSize) return;

    BallTripStage stage;
    double animationValue;

    if (ballDepartureAnimation.status == AnimationStatus.forward) {
      stage = BallTripStage.departure;
      animationValue = ballDepartureAnimation.value;
    } else if (ballTravelAnimation.status == AnimationStatus.forward) {
      stage = BallTripStage.travel;
      animationValue = ballTravelAnimation.value;
    } else if (ballArrivalAnimation.status == AnimationStatus.forward) {
      stage = BallTripStage.arrival;
      animationValue = ballArrivalAnimation.value;
    } else {
      // This prevents a state where the value of an animation controller has
      // been reset to 0, but no other controller has been started yet.
      return;
    }

    final newLine = Line2d.from(travelLine);

    switch (stage) {
      case BallTripStage.travel:
        newLine.padStartEnd(
          leftTravelSequence.transform(animationValue),
          rightTravelSequence.transform(animationValue),
        );
        break;
      case BallTripStage.arrival:
        newLine.padEnd(arrivalSequence.transform(animationValue));
        break;
      case BallTripStage.departure:
        newLine.padStart(departureSequence.transform(animationValue));
        break;
    }

    // Only repaint when necessary.
    if (newLine == paddedTravelLine) {
      return;
    }

    paddedTravelLine = newLine;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Need to translate by the offset and subtract the offset
    // set in performResize again.
    canvas.translate(offset.dx + -compositionData.offset.dx, offset.dy + -compositionData.offset.dy);

    final travelPath = paddedTravelLine.pathWithWidth(strokeWidth), startPath = startLine.pathWithWidth(strokeWidth), endPath = endLine.pathWithWidth(strokeWidth);
    canvas.drawShadow(
      Path.from(travelPath)..addPath(startPath, Offset.zero)..addPath(endPath, Offset.zero),
      _shadowColor,
      size.height / 99,
      false,
    );

    final rect = offset & size,
        paint = Paint()
          ..shader = ui.Gradient.linear(
            rect.topRight,
            rect.bottomCenter,
            [
              _secondaryColor,
              _primaryColor,
            ],
          );
    canvas.drawPath(travelPath, paint);
    canvas.drawPath(startPath, paint);
    canvas.drawPath(endPath, paint);

    canvas.restore();
  }
}
