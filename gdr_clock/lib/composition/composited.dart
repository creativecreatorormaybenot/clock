import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class CompositedClock extends MultiChildRenderObjectWidget {
  final Animation<double> ballArrivalAnimation, ballDepartureAnimation, bounceAwayAnimation, bounceBackAnimation;

  /// The [children] need to cover each component type in [ClockComponent], which can be specified in the [RenderObject.parentData] using [ClockChildrenParentData].
  /// Every component can only exist exactly once.
  /// Notice that the order of the [children] does not affect the layout or paint order.
  CompositedClock({
    Key key,
    List<Widget> children,
    @required this.ballArrivalAnimation,
    @required this.ballDepartureAnimation,
    @required this.bounceAwayAnimation,
    @required this.bounceBackAnimation,
  })  : assert(ballArrivalAnimation != null),
        assert(ballDepartureAnimation != null),
        assert(bounceAwayAnimation != null),
        assert(bounceBackAnimation != null),
        super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCompositedClock(
      ballArrivalAnimation: ballArrivalAnimation,
      ballDepartureAnimation: ballDepartureAnimation,
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
//  digitalTime,
  location,

  /// Slide where the [ball] rolls down.
  slide,
  temperature,
  weather,
}

class ClockChildrenParentData extends CompositionChildrenParentData<ClockComponent> {
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
  final Animation<double> ballArrivalAnimation, ballDepartureAnimation, bounceAwayAnimation, bounceBackAnimation;

  RenderCompositedClock({
    this.ballArrivalAnimation,
    this.ballDepartureAnimation,
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
    bounceAwayAnimation.addListener(markNeedsLayout);
    bounceBackAnimation.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    ballArrivalAnimation.removeListener(markNeedsLayout);
    ballDepartureAnimation.removeListener(markNeedsLayout);
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
        // It should fly into view faster than it leaves the view again.
        -ball.size.height * 3,
      ),
          ballDestination = analogClockBasePosition + analogTime.size.onlyWidth.offset / 2 - Offset(ball.size.width / 2, ball.size.height / 1.42),
          ballEndPosition = Offset(
        size.width * 1.2 / 4,
        -ball.size.height * 2,
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

      if (ballDepartureAnimation.status != AnimationStatus.forward) {
        ballData.offset = Offset.lerp(ballStartPosition, ballDestination, ballArrivalAnimation.value);
      } else {
        ballData.offset = Offset.lerp(ballDestination, ballEndPosition, ballDepartureAnimation.value);
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
    //</editor-fold>
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Clip to the given size to not exceed to 5:3 area imposed by the challenge.
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (context, offset) {
      super.paint(context, offset);

      // Draw components in the actual draw order.
      // The order in which the children are passed to the widget does not matter
      // and is alphabetical, i.e. the following is the draw order.
      paintChild(ClockComponent.background);
      paintChild(ClockComponent.location);
      paintChild(ClockComponent.date);
      paintChild(ClockComponent.temperature);
      paintChild(ClockComponent.weather);
      paintChild(ClockComponent.analogTime);
      paintChild(ClockComponent.slide);
      paintChild(ClockComponent.ball);
    });
  }
}
