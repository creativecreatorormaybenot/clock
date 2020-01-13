import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:canvas_clock/clock.dart';

class Slide extends LeafRenderObjectWidget {
  final Animation<double> ballTravelAnimation, ballArrivalAnimation, ballDepartureAnimation;

  final Color curveColor, shadowColor;

  Slide({
    Key key,
    @required this.ballTravelAnimation,
    @required this.ballArrivalAnimation,
    @required this.ballDepartureAnimation,
    @required this.curveColor,
    @required this.shadowColor,
  })  :
        assert(ballTravelAnimation != null),
        assert(ballArrivalAnimation != null),
        assert(ballDepartureAnimation != null),
        assert(curveColor != null),
        assert(shadowColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSlide(
      ballTravelAnimation: ballTravelAnimation,
      ballArrivalAnimation: ballArrivalAnimation,
      ballDepartureAnimation: ballDepartureAnimation,
      curveColor: curveColor,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSlide renderObject) {
    renderObject
      ..curveColor = curveColor
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
    this.ballTravelAnimation, this.ballArrivalAnimation, this.ballDepartureAnimation,
    Color curveColor,
    Color shadowColor,
  })  : _curveColor = curveColor,
        _shadowColor = shadowColor,
        super(ClockComponent.slide);

  Color _curveColor, _shadowColor;

  set curveColor(Color value) {
    assert(value != null);

    if (_curveColor == value) {
      return;
    }

    _curveColor = value;
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
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData.hasSemanticsInformation = false;

    ballTravelAnimation.addListener(markNeedsPaint);
    ballArrivalAnimation.addListener(markNeedsPaint);
    ballDepartureAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    ballTravelAnimation.removeListener(markNeedsPaint);
    ballArrivalAnimation.removeListener(markNeedsPaint);
    ballDepartureAnimation.removeListener(markNeedsPaint);

    super.detach();
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    BallTripStage stage;
    double animationValue;

    if (ballDepartureAnimation.status == AnimationStatus.forward) {
      stage = BallTripStage.departure;
      animationValue = ballDepartureAnimation.value;
    } else if (ballTravelAnimation.status == AnimationStatus.forward) {
      stage = BallTripStage.travel;
      animationValue = ballTravelAnimation.value;
    } else {
      stage = BallTripStage.arrival;
      animationValue = ballArrivalAnimation.value;
    }


    final canvas = context.canvas;

    canvas.save();
    // Translate to the top left of this box.
    canvas.translate(offset.dx, offset.dy);

    // The positions are already given relative to the top left.
    final start = compositionData.start, end = compositionData.end, destination = compositionData.destination;

    // Need to know where the start line is located in order to
    // properly add padding to account for the ball's size.
    final startLeft = start.dx < end.dx;

    final ballRadius = compositionData.ballRadius;

    // The stroke width is drawn out equally in both directions from
    // the 0 width line and thus, the lines need to be shifted a bit more
    // if they should only touch the ball instead of overlapping.
    final strokeWidth = size.shortestSide / 43, shiftFactor = 1 + strokeWidth / 2 / ballRadius;

    var startLine = Line2d(start: start, end: destination)
          ..padStart(1.6)
          ..padEnd(.99),
        endLine = Line2d(start: end, end: destination)
          ..padEnd(.7)
          ..padStart(1.5),
        travelLine = Line2d(start: end, end: start);

    // The start line should touch the ball on its side.
    // The same also goes for the end line, which is
    // why startLeft is required.
    startLine.shift(startLine.normal.offset * ballRadius * (startLeft ? shiftFactor : -shiftFactor));
    endLine.shift(endLine.normal.offset * ballRadius * (startLeft ? -shiftFactor : shiftFactor));

    final travelLength = travelLine.length, ballLengthFraction = ballRadius * 5 / travelLength;

    travelLine.pad(1.017);

    switch (stage) {
      case BallTripStage.travel:
        final leftSequence = TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1 - ballLengthFraction,
              end: 1,
            ).chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn)),
            weight: ballRadius / 28,
          ),
          TweenSequenceItem(
            tween: ConstantTween<double>(1),
            weight: travelLength,
          ),
        ]),
            rightSequence = TweenSequence([
          TweenSequenceItem(
            tween: ConstantTween<double>(1),
            weight: travelLength,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1,
              end: 1 - ballLengthFraction,
            ).chain(CurveTween(curve: const AccelerationCurve())),
            weight: ballRadius / 3,
          ),
        ]);

        travelLine.padStartEnd(
          leftSequence.transform(animationValue),
          rightSequence.transform(animationValue),
        );
        break;
      case BallTripStage.arrival:
        final sequence = TweenSequence([
          TweenSequenceItem(
            tween: ConstantTween<double>(1 - ballLengthFraction),
            weight: ballRadius * 20,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1 - ballLengthFraction,
              end: 1,
            ).chain(CurveTween(curve: const AccelerationCurve())),
            weight: startLine.length,
          ),
        ]);

        travelLine.padEnd(sequence.transform(animationValue));
        break;
      case BallTripStage.departure:
        final sequence = TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1,
              end: 1 - ballLengthFraction,
            ).chain(CurveTween(curve: Curves.decelerate)),
            weight: endLine.length,
          ),
          TweenSequenceItem(
            tween: ConstantTween<double>(1 - ballLengthFraction),
            weight: ballRadius * 8,
          ),
        ]);

        travelLine.padStart(sequence.transform(animationValue));
        break;
    }

    travelLine
        // The line should touch the ball's bottom.
        .shift(travelLine.normal.offset * ballRadius * shiftFactor);

    final travelPath = travelLine.pathWithWidth(strokeWidth), startPath = startLine.pathWithWidth(strokeWidth), endPath = endLine.pathWithWidth(strokeWidth);
    canvas.drawShadow(
      Path.from(travelPath)..addPath(startPath, Offset.zero)..addPath(endPath, Offset.zero),
      _shadowColor,
      size.height / 99,
      false,
    );

    final paint = Paint()..color = _curveColor;
    canvas.drawPath(travelPath, paint);
    canvas.drawPath(startPath, paint);
    canvas.drawPath(endPath, paint);

    canvas.restore();
  }
}
