import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class CompositedClock extends MultiChildRenderObjectWidget {
  final Animation<double> ballArrivalAnimation, ballDepartureAnimation, ballTravelAnimation, bounceAwayAnimation, bounceBackAnimation;

  /// The [children] need to cover each component type in [ClockComponent], which can be specified in the [RenderObject.parentData] using [ClockChildrenParentData].
  /// Every component can only exist exactly once.
  /// Notice that the order of [children] does not affect the layout or paint order.
  CompositedClock({
    Key key,
    List<Widget> children,
    @required this.ballArrivalAnimation,
    @required this.ballDepartureAnimation,
    @required this.ballTravelAnimation,
    @required this.bounceAwayAnimation,
    @required this.bounceBackAnimation,
  })  : assert(ballArrivalAnimation != null),
        assert(ballDepartureAnimation != null),
        assert(ballTravelAnimation != null),
        assert(bounceAwayAnimation != null),
        assert(bounceBackAnimation != null),
        super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCompositedClock(
      ballArrivalAnimation: ballArrivalAnimation,
      ballDepartureAnimation: ballDepartureAnimation,
      ballTravelAnimation: ballTravelAnimation,
      bounceAwayAnimation: bounceAwayAnimation,
      bounceBackAnimation: bounceBackAnimation,
    );
  }
}

enum ClockComponent {
  analogTime,
  background,
  ball,
  date,
  digitalTime,
  location,

  /// Slide where the [ball] rolls down.
  slide,
  temperature,
  weather,
}

/// The order in which the children are passed to the widget does not matter
/// and is alphabetical, i.e. the following is the paint order.
const List<ClockComponent> paintOrder = [
  ClockComponent.background,
  ClockComponent.location,
  ClockComponent.date,
  ClockComponent.temperature,
  ClockComponent.weather,
  ClockComponent.analogTime,
  ClockComponent.digitalTime,
  ClockComponent.slide,
  ClockComponent.ball,
];

class ClockChildrenParentData extends CompositionChildrenParentData<ClockComponent> {
  bool hasSemanticsInformation;

  Map<ClockComponent, Rect> _rects;

  void _addRect(RenderBox child) {
    final childParentData = child.parentData as ClockChildrenParentData;
    _rects[childParentData.childType] = childParentData.offset & child.size;
  }

  Rect rectOf(ClockComponent component) {
    assert(childType == ClockComponent.background, 'Only the background component can access sizes and offsets of the other children.');
    final rect = _rects[component];
    assert(rect != null, 'No $Rect was provided for $component. If the rect of this child should be accessible from $childType, this needs to be changed in $RenderCompositedClock.');
    return rect;
  }
}

class RenderCompositedClock extends RenderComposition<ClockComponent, ClockChildrenParentData, CompositedClock> {
  final Animation<double> ballArrivalAnimation, ballDepartureAnimation, ballTravelAnimation, bounceAwayAnimation, bounceBackAnimation;

  RenderCompositedClock({
    this.ballArrivalAnimation,
    this.ballDepartureAnimation,
    this.ballTravelAnimation,
    this.bounceAwayAnimation,
    this.bounceBackAnimation,
  }) : super(ClockComponent.values);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! ClockChildrenParentData) {
      child.parentData = ClockChildrenParentData()..valid = false;
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    ballArrivalAnimation.addListener(markNeedsLayout);
    ballDepartureAnimation.addListener(markNeedsLayout);
    ballTravelAnimation.addListener(markNeedsLayout);
    bounceAwayAnimation.addListener(markNeedsLayout);
    bounceBackAnimation.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    ballArrivalAnimation.removeListener(markNeedsLayout);
    ballDepartureAnimation.removeListener(markNeedsLayout);
    ballTravelAnimation.removeListener(markNeedsLayout);
    bounceAwayAnimation.removeListener(markNeedsLayout);
    bounceBackAnimation.removeListener(markNeedsLayout);

    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();

    // The children use this size and the challenge provides a fixed size anyway.
    size = constraints.biggest;

    //<editor-fold desc="Laying out children">
    // Background
    final background = layoutChildren[ClockComponent.background], backgroundData = layoutParentData[ClockComponent.background];

    backgroundData._rects = {};
    final provideRect = backgroundData._addRect;

    background.layout(BoxConstraints.tight(size));

    // Ball
    final ball = layoutChildren[ClockComponent.ball], ballData = layoutParentData[ClockComponent.ball];
    ball.layout(constraints.loosen(), parentUsesSize: true);

    // Slide
    final slide = layoutChildren[ClockComponent.slide], slideData = layoutParentData[ClockComponent.slide];

    // Analog time (paint order is different, but the weather component depends on the size of the analog component).
    final analogTime = layoutChildren[ClockComponent.analogTime], analogTimeData = layoutParentData[ClockComponent.analogTime];
    analogTime.layout(
      BoxConstraints.tight(Size.fromRadius(size.height / 2.9)),
      parentUsesSize: true,
    );

    // The ball destination depends on where the analog clock is positioned, which depends on the size of the analog component.
    () {
      final analogClockBasePosition = Offset(
        size.width / 2 - analogTime.size.width / 2.36,
        size.height / 2 - analogTime.size.height / 2.7,
      );

      final ballStartPosition = Offset(
        size.width * 3 / 4,
        // It should slowly come a bit more into view
        // (h / 2 for the end position).
        -ball.size.height / 4,
      ),
          ballDestination = analogClockBasePosition + analogTime.size.onlyWidth.offset / 2 - Offset(ball.size.width / 2, ball.size.height / 1.42),
          ballEndPosition = Offset(
        size.width * 1.2 / 4,
        -ball.size.height / 2,
      );

      final ballArrivalTween = Tween(
        begin: ballStartPosition,
        end: ballDestination,
      ),
          ballDepartureTween = Tween(
        begin: ballDestination,
        end: ballEndPosition,
      ),
          ballTravelTween = Tween(
        begin: ballDepartureTween.end,
        end: ballArrivalTween.begin,
      );

      final slideRect = Rect.fromPoints(
        Offset.lerp(
          ballStartPosition,
          ballDestination,
          3 / 4,
        ).plus(ball.size),
        ballStartPosition.plus(ball.size),
      );

      slide.layout(BoxConstraints.tight(slideRect.size), parentUsesSize: false);
      slideData.offset = slideRect.topLeft;

      print('RenderCompositedClock.performLayout ${ballTravelAnimation.value} ${ballArrivalAnimation.value} ${ballDepartureAnimation.value}');

      if (ballDepartureAnimation.status == AnimationStatus.forward) {
        ballData.offset = ballDepartureTween.evaluate(ballDepartureAnimation);
      } else if (ballTravelAnimation.status == AnimationStatus.forward) {
        ballData.offset = ballTravelTween.evaluate(ballTravelAnimation);
      } else {
        ballData.offset = ballArrivalTween.evaluate(ballArrivalAnimation);
      }

      final ballRect = ballData.offset & ball.size, analogClockBaseRect = analogClockBasePosition & analogTime.size;

      var intersection = Offset.zero;

      if (ballDepartureAnimation.status == AnimationStatus.forward) {
        // This is not really the intersection anymore, but it ensures
        // that the analog component is not dragged back when the animation
        // has not caught up to the intersection and the ball is already
        // departing again.
        intersection = Offset(0, (ballDestination.dy + ball.size.height) - analogClockBasePosition.dy);
      } else if (analogClockBaseRect.overlaps(ballRect)) {
        intersection = ballRect.intersect(analogClockBaseRect).size.onlyHeight.offset;
      }

      final animatedBounce = ball.size.onlyHeight.offset / 2 * (bounceAwayAnimation.value - bounceBackAnimation.value);

      Offset offset;

      if (intersection.dy > animatedBounce.dy && bounceAwayAnimation.status == AnimationStatus.forward) {
        offset = intersection;
      } else {
        offset = animatedBounce;
      }

      analogTimeData.offset = analogClockBasePosition + offset;
    }();
    provideRect(ball);

    provideRect(analogTime);

    // Weather
    final weather = layoutChildren[ClockComponent.weather], weatherData = layoutParentData[ClockComponent.weather];
    weather.layout(
      BoxConstraints.tight(Size.fromRadius(size.height / 4)),
      parentUsesSize: true,
    );

    // The anonymous function hides the clearanceFactor variable later on.
    () {
      final clearanceFactor = 1 / 31;
      weatherData.offset = Offset(
        weather.size.width * clearanceFactor,
        weather.size.height * clearanceFactor + size.height / 7,
      );
    }();
    provideRect(weather);

    // Temperature
    final temperature = layoutChildren[ClockComponent.temperature], temperatureData = layoutParentData[ClockComponent.temperature];

    () {
      final width = size.width / 6;
      temperature.layout(
        BoxConstraints(maxWidth: width, minHeight: width, maxHeight: size.height),
        parentUsesSize: true,
      );

      temperatureData.offset = Offset(
        size.width - temperature.size.width - size.width / 21,
        size.height / 2 - temperature.size.height / 2,
      );
    }();
    provideRect(temperature);

    // Location
    final location = layoutChildren[ClockComponent.location], locationData = layoutParentData[ClockComponent.location];

    location.layout(BoxConstraints(maxWidth: weather.size.width, maxHeight: size.height), parentUsesSize: true);
    locationData.offset = Offset(weatherData.offset.dx, weatherData.offset.dy / 3 - location.size.height / 2);

    // Date
    final date = layoutChildren[ClockComponent.date], dateData = layoutParentData[ClockComponent.date];

    date.layout(BoxConstraints(maxWidth: weather.size.width, maxHeight: size.height), parentUsesSize: false);
    dateData.offset = ExtendedOffset(locationData.offset).plus(location.size.onlyHeight);

    // Digital clock
    final digitalTime = layoutChildren[ClockComponent.digitalTime], digitalTimeData = layoutParentData[ClockComponent.digitalTime];

    digitalTime.layout(BoxConstraints(maxWidth: weather.size.width, maxHeight: size.height), parentUsesSize: true);
    digitalTimeData.offset = Offset(weatherData.offset.dx + weather.size.width / 2.45 - digitalTime.size.width / 2, size.height - weather.size.height / 3 - digitalTime.size.height / 2);
    //</editor-fold>
  }

  /// Ensures that only composition children that have set
  /// [ClockChildrenParentData.hasSemanticsInformation] to `true`
  /// will be visited for semantics.
  ///
  /// The children are visited in the [paintOrder]. The reason I do
  /// that is that the [RenderObject.visitChildrenForSemantics]
  /// documentation states that this should be the way, however,
  /// my tests with TalkBack on Android have shown that the order
  /// does not matter.
  @override
  void visitChildrenForSemantics(visitor) {
    final toBeVisited = <ClockComponent, RenderBox>{};

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as ClockChildrenParentData, component = childParentData.childType;

      assert(childParentData.hasSemanticsInformation != null, 'The render object ($child) for $component did not set $ClockChildrenParentData.hasSemanticsInformation properly.');

      if (childParentData.hasSemanticsInformation) toBeVisited[component] = child;

      child = childParentData.nextSibling;
    }

    for (final component in paintOrder) {
      if (toBeVisited.containsKey(component)) visitor(toBeVisited[component]);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Clip to the given size to not exceed to 5:3 area imposed by the challenge.
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (context, offset) {
      super.paint(context, offset);

      // Draw components in the actual draw order.
      paintOrder.forEach(paintChild);
    });
  }
}
