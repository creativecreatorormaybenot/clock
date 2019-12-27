import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class CompositedClock extends MultiChildRenderObjectWidget {
  /// The [children] need to cover each component type in [ClockComponent], which can be specified in the [RenderObject.parentData] using [ClockChildrenParentData].
  /// Every component can only exist exactly once.
  /// Notice that the order of the [children] does not affect the layout or paint order.
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
  date,
//  digitalTime,
  location,
  temperature,
  weather,
}

class ClockChildrenParentData
    extends CompositionChildrenParentData<ClockComponent> {
  Map<ClockComponent, Rect> _rects;

  void _addRect(RenderBox child) {
    final childParentData = child.parentData as ClockChildrenParentData;
    _rects[childParentData.childType] = childParentData.offset & child.size;
  }

  Rect rectOf(ClockComponent component) {
    assert(childType == ClockComponent.background,
        'Only the background component can access sizes and offsets of the other children.');
    final rect = _rects[component];
    assert(rect != null,
        'No $Rect was provided for $component. If the rect of this child should be accessible from $childType, this needs to be changed in $RenderCompositedClock.');
    return rect;
  }
}

class RenderCompositedClock extends RenderComposition<ClockComponent,
    ClockChildrenParentData, CompositedClock> {
  RenderCompositedClock() : super(ClockComponent.values);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! ClockChildrenParentData) {
      child.parentData = ClockChildrenParentData()..valid = false;
    }
  }

  @override
  void performLayout() {
    super.performLayout();

    // The children use this size and the challenge provides a fixed size anyway.
    size = constraints.biggest;

    //<editor-fold desc="Laying out children">
    // Background
    final background = layoutChildren[ClockComponent.background],
        backgroundData = layoutParentData[ClockComponent.background];

    backgroundData._rects = {};
    final provideRect = backgroundData._addRect;

    background.layout(BoxConstraints.tight(size));

    // Analog time (paint order is different, but the weather component depends on the size of the analog component).
    final analogTime = layoutChildren[ClockComponent.analogTime],
        analogTimeData = layoutParentData[ClockComponent.analogTime];
    analogTime.layout(
      BoxConstraints.tight(Size.fromRadius(size.height / 2.9)),
      parentUsesSize: true,
    );
    analogTimeData.offset = Offset(
      size.width / 2 - analogTime.size.width / 2.36,
      size.height / 2 - analogTime.size.height / 3,
    );
    provideRect(analogTime);

    // Weather
    final weather = layoutChildren[ClockComponent.weather],
        weatherData = layoutParentData[ClockComponent.weather];
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
    final temperature = layoutChildren[ClockComponent.temperature],
        temperatureData = layoutParentData[ClockComponent.temperature];

    () {
      final width = size.width / 6;
      temperature.layout(
        BoxConstraints(
            maxWidth: width, minHeight: width, maxHeight: size.height),
        parentUsesSize: true,
      );

      temperatureData.offset = Offset(
        size.width - temperature.size.width - size.width / 21,
        size.height / 2 - temperature.size.height / 2,
      );
    }();
    provideRect(temperature);

    // Location
    final location = layoutChildren[ClockComponent.location],
        locationData = layoutParentData[ClockComponent.location];

    location.layout(
        BoxConstraints(maxWidth: weather.size.width, maxHeight: size.height),
        parentUsesSize: true);
    locationData.offset = Offset(weatherData.offset.dx,
        weatherData.offset.dy / 3 - location.size.height / 2);

    // Date
    final date = layoutChildren[ClockComponent.date],
        dateData = layoutParentData[ClockComponent.date];

    date.layout(
        BoxConstraints(maxWidth: weather.size.width, maxHeight: size.height),
        parentUsesSize: false);
    dateData.offset = ExtendedOffset(locationData.offset).plus(location.size.onlyHeight);
    //</editor-fold>
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Clip to the given size to not exceed to 5:3 area imposed by the challenge.
    context.pushClipRect(needsCompositing, offset, Offset.zero & size,
        (context, offset) {
      super.paint(context, offset);

      // Draw components.
      paintChild(ClockComponent.background);
      paintChild(ClockComponent.location);
      paintChild(ClockComponent.date);
      paintChild(ClockComponent.temperature);
      paintChild(ClockComponent.weather);
      paintChild(ClockComponent.analogTime);
    });
  }
}
