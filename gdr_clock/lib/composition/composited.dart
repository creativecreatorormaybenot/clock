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
  weather,
//  digitalTime,
//  temperature,
}

class ClockChildrenParentData
    extends CompositionChildrenParentData<ClockComponent> {
  Map<ClockComponent, Rect> _rects;

  void _addRect(RenderBox child) {
    final childParentData =
        child.parentData as ClockChildrenParentData;
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

  Offset hitPosition;

  @override
  bool hitTestSelf(Offset position) {
    return true;
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    hitPosition = globalToLocal(event.position);
    markNeedsLayout();
    super.handleEvent(event, entry);
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

    background.layout(BoxConstraints.tight(constraints.biggest));

    // Analog time (paint order is different, but the weather component depends on the size of the analog component).
    final analogTime = layoutChildren[ClockComponent.analogTime],
        analogTimeData = layoutParentData[ClockComponent.analogTime];
    analogTime.layout(
      BoxConstraints.tight(Size.fromRadius(constraints.biggest.height / 2.9)),
      parentUsesSize: true,
    );
    analogTimeData.offset = Offset(
      (hitPosition?.dx ?? size.width / 2) - analogTime.size.width / 2,
      (hitPosition?.dy ?? size.height / 2) -
          analogTime.size.height / 2, // todo /3 and remove hitPosition
    );
    provideRect(analogTime);

    // Weather
    final weather = layoutChildren[ClockComponent.weather],
        weatherData = layoutParentData[ClockComponent.weather];
    weather.layout(
      BoxConstraints.tight(Size.fromRadius(constraints.biggest.height / 4)),
      parentUsesSize: true,
    );

    final clearanceFactor = 1 / 17;
    weatherData.offset = Offset(
      weather.size.width * clearanceFactor,
      weather.size.height * clearanceFactor,
    );
    provideRect(weather);
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
      paintChild(ClockComponent.weather);
      paintChild(ClockComponent.analogTime);
    });
  }
}
