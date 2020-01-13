import 'dart:ui';

import 'package:canvas_clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CompositedClock extends MultiChildRenderObjectWidget {
  /// The [children] need to cover each component type in [ClockComponent], which can be specified in the [RenderObject.parentData] using [ClockChildrenParentData].
  /// Every component can only exist exactly once.
  /// Notice that the order of [children] does not affect the layout or paint order.
  CompositedClock({
    Key key,
    List<Widget> children,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCompositedClock();
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
}

class RenderCompositedClock extends RenderComposition<ClockComponent, ClockChildrenParentData, CompositedClock> {
  RenderCompositedClock() : super(ClockComponent.values);

  @override
  bool get isRepaintBoundary => false;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! ClockChildrenParentData) {
      if (child is RenderBackground) {
        child.parentData = BackgroundParentData();
      } else if (child is RenderSlide) {
        child.parentData = SlideParentData();
      } else if (child is RenderBall) {
        child.parentData = BallParentData();
      } else if (child is RenderDigitalTime) {
        child.parentData = DigitalTimeParentData();
      } else if (child is RenderAnalogTime) {
        child.parentData = AnalogTimeParentData();
      } else {
        child.parentData = ClockChildrenParentData();
      }

      (child.parentData as ClockChildrenParentData).valid = false;
    }
  }

  @override
  void performLayout() {
    super.performLayout();

    print('RenderCompositedClock.performLayout ${DateTime.now()}');

    // The children use this size and the challenge provides a fixed size anyway.
    size = constraints.biggest;

    //<editor-fold desc="Laying out children">
    // Background
    final background = layoutChildren[ClockComponent.background], backgroundData = layoutParentData[ClockComponent.background] as BackgroundParentData;

    backgroundData.clearRects();

    background.layout(BoxConstraints.tight(size));

    // Ball
    final ball = layoutChildren[ClockComponent.ball], ballData = layoutParentData[ClockComponent.ball] as BallParentData, ballRadius = constraints.biggest.height / 21, ballSize = Size.fromRadius(ballRadius);

    // Slide
    final slide = layoutChildren[ClockComponent.slide], slideData = layoutParentData[ClockComponent.slide] as SlideParentData;

    // Analog time (paint order is different, but the weather component depends on the size of the analog component).
    final analogTime = layoutChildren[ClockComponent.analogTime], analogTimeData = layoutParentData[ClockComponent.analogTime] as AnalogTimeParentData, analogTimeSize = Size.fromRadius(size.height / 2.9);

    // The ball destination depends on where the analog clock is positioned, which depends on the size of the analog component.
    () {
      final analogClockBasePosition = Offset(
        size.width / 2 - analogTimeSize.width / 2.36,
        size.height / 2 - analogTimeSize.height / 2.7,
      );

      final ballStartPosition = Offset(
        size.width * 3 / 4,
        // It should slowly come a bit more into view.
        // The ball shows h / 2 at the end position
        // as the positions mark the center point.
        ballSize.height / 4,
      ),
          ballDestination = analogClockBasePosition +
              analogTimeSize.onlyWidth.offset / 2 -
              // The ball should only touch the clock and not fly into it.
              ballSize.onlyHeight.offset / 2,
          ballEndPosition = Offset(
        size.width * 1.2 / 4,
        0,
      );

      final ballRect = Rect.fromPoints(
        ballEndPosition,
        ballStartPosition,
      )
          .include(ballDestination)
          // The positions are the center of where the ball should be.
          // Thus, the slide rect needs to be inflated.
          .inflate(ballSize.longestSide / 2);

      // Slide sizes and positions itself accordingly.
      slideData
        ..end = ballEndPosition
        ..start = ballStartPosition
        ..destination = ballDestination
        ..ballRadius = ballSize.longestSide / 2;
      slide.layout(constraints.loosen(), parentUsesSize: false);

      ballData
        ..startPosition = ballStartPosition - ballRect.topLeft
        ..endPosition = ballEndPosition - ballRect.topLeft
        ..destination = ballDestination - ballRect.topLeft
        ..radius = ballRadius
        ..offset = ballRect.topLeft;
      // Need to provide positions first.
      ball.layout(BoxConstraints.tight(ballRect.size), parentUsesSize: false);

      final bounce = ballSize.onlyHeight.offset / 4;

      backgroundData.analogTimeBounce = bounce;

      analogTimeData
        ..offset = analogClockBasePosition
        ..bounce = bounce;
      analogTime.layout(BoxConstraints.tight(analogTimeSize + bounce), parentUsesSize: false);
    }();

    backgroundData.addRect(ClockComponent.analogTime, analogTimeData.offset, analogTimeSize);

    // Weather
    final weather = layoutChildren[ClockComponent.weather], weatherData = layoutParentData[ClockComponent.weather], weatherSize = Size.fromRadius(size.height / 4);
    weather.layout(BoxConstraints.tight(weatherSize), parentUsesSize: false);

    // The anonymous function hides the clearanceFactor variable later on.
    () {
      final clearanceFactor = 1 / 31;
      weatherData.offset = Offset(
        weatherSize.width * clearanceFactor,
        weatherSize.height * clearanceFactor + size.height / 7,
      );
    }();
    backgroundData.addRect(ClockComponent.weather, weatherData.offset, weatherSize);

    // Temperature
    final temperature = layoutChildren[ClockComponent.temperature], temperatureData = layoutParentData[ClockComponent.temperature], temperatureSize = Size(size.width / 6, size.height / 1.2);

    temperature.layout(BoxConstraints.tight(temperatureSize), parentUsesSize: false);

    temperatureData.offset = Offset(
      size.width - temperatureSize.width - size.width / 21,
      size.height / 2 - temperatureSize.height / 2,
    );
    backgroundData.addRect(ClockComponent.temperature, temperatureData.offset, temperatureSize);

    // Location
    final location = layoutChildren[ClockComponent.location], locationData = layoutParentData[ClockComponent.location];

    location.layout(
      BoxConstraints(maxWidth: weatherSize.width, maxHeight: size.height),
      // The text painter determines the size, hence, there is no way to determine it here
      // (except creating the text painter here).
      // This is not critical as long as the location is not updated frequently, which it is not.
      parentUsesSize: true,
    );
    locationData.offset = Offset(weatherData.offset.dx, weatherData.offset.dy / 3 - location.size.height / 2);

    // Date
    final date = layoutChildren[ClockComponent.date], dateData = layoutParentData[ClockComponent.date];

    date.layout(BoxConstraints(maxWidth: weatherSize.width, maxHeight: size.height), parentUsesSize: false);
    dateData.offset = ExtendedOffset(locationData.offset).plus(location.size.onlyHeight);

    // Digital clock
    final digitalTime = layoutChildren[ClockComponent.digitalTime], digitalTimeData = layoutParentData[ClockComponent.digitalTime] as DigitalTimeParentData;

    // The position needs to be assigned before layout
    // as it is used in the layout function of digital time.
    digitalTimeData.position = Offset(weatherData.offset.dx + weatherSize.width / 2.45, size.height - weatherSize.height / 3);
    digitalTime.layout(
      BoxConstraints(maxWidth: weatherSize.width, maxHeight: size.height),
      // This is crucial because the layout of the
      // digital time changes all the time.
      parentUsesSize: false,
    );
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
    print('RenderCompositedClock.paint ${DateTime.now()}');

    // Clip to the given size to not exceed to 5:3 area imposed by the challenge.
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (context, offset) {
      super.paint(context, offset);

      // Draw components in the actual draw order.
      paintOrder.forEach(paintChild);
    });
  }
}
