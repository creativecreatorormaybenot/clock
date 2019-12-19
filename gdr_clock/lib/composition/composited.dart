import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class CompositedClock extends MultiChildRenderObjectWidget {
  /// The [children] need to cover each component type in [ClockComponent], which can be specified in the [RenderObject.parentData] using [CompositedClockChildrenParentData].
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

class CompositedClockChildrenParentData
    extends CompositionChildrenParentData {
  Map<ClockComponent, Rect> _rects;

  void _addRect(RenderBox child) {
    final childParentData =
        child.parentData as CompositedClockChildrenParentData;
    _rects[childParentData.child] = childParentData.offset & child.size;
  }

  Rect rectOf(ClockComponent component) {
    assert(child == ClockComponent.background,
        'Only the background component can access sizes and offsets of the other children.');
    final rect = _rects[component];
    assert(rect != null,
        'No $Rect was provided for $component. If the rect of this child should be accessible from ${this.child}, this needs to be changed in $RenderCompositedClock.');
    return rect;
  }
}

class RenderCompositedClock extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            CompositedClockChildrenParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            CompositedClockChildrenParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! CompositedClockChildrenParentData) {
      child.parentData = CompositedClockChildrenParentData()..valid = false;
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
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    //<editor-fold desc="Setup">
    final children = <ClockComponent, RenderBox>{},
        parentData = <ClockComponent, CompositedClockChildrenParentData>{};

    var child = firstChild;
    while (child != null) {
      final childParentData =
              child.parentData as CompositedClockChildrenParentData,
          component = childParentData.child;

      if (!childParentData.valid) throw CompositionError(child: child);
      if (children.containsKey(component)) {
        throw CompositionError(
            message:
                'The children passed to CompositedClock contain the component type ${describeEnum(component)} more than once. '
                'Every component can only be passed exactly once.');
      }

      children[component] = child;
      parentData[component] = childParentData;

      child = childParentData.nextSibling;
    }

    final missingComponents = ClockComponent.values
        .where((component) => !children.containsKey(component));

    if (missingComponents.isNotEmpty) {
      throw CompositionError(
          message:
              'The children passed to CompositedClock do not cover every component of ${ClockComponent.values}. '
              'You need to pass every component exactly once and specify the component type correctly using CompositedClockChildrenParentData.\n'
              'Missing components are $missingComponents.');
    }

    // This should prevent accidental use of child.
    child = null;
    //</editor-fold>

    // The children use this size and the challenge provides a fixed size anyway.
    size = constraints.biggest;

    //<editor-fold desc="Laying out children">
    // Background
    final background = children[ClockComponent.background],
        backgroundData = parentData[ClockComponent.background];

    backgroundData._rects = {};
    final provideRect = backgroundData._addRect;

    background.layout(BoxConstraints.tight(constraints.biggest));

    // Analog time (paint order is different, but the weather component depends on the size of the analog component).
    final analogTime = children[ClockComponent.analogTime],
        analogTimeData = parentData[ClockComponent.analogTime];
    analogTime.layout(
      BoxConstraints.tight(Size.fromRadius(constraints.biggest.height / 2.9)),
      parentUsesSize: true,
    );
    analogTimeData.offset = Offset(
      (hitPosition?.dx ?? size.width / 2) - analogTime.size.width / 2,
      (hitPosition?.dy ?? size.height / 2) - analogTime.size.height / 2, // todo /3 and remove hitPosition
    );
    provideRect(analogTime);

    // Weather
    final weather = children[ClockComponent.weather],
        weatherData = parentData[ClockComponent.weather];
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
    context.pushClipRect(
        needsCompositing, offset, Offset.zero & size,
        (context, offset) {
      //<editor-fold desc="Setup">
      final children = <ClockComponent, RenderBox>{},
          parentData = <ClockComponent, CompositedClockChildrenParentData>{};

      var child = firstChild;
      while (child != null) {
        final childParentData =
                child.parentData as CompositedClockChildrenParentData,
            component = childParentData.child;

        children[component] = child;
        parentData[component] = childParentData;

        child = childParentData.nextSibling;
      }

      void paint(ClockComponent component) => context.paintChild(
          children[component], parentData[component].offset + offset);
      //</editor-fold>

      // Draw components.
      paint(ClockComponent.background);
      paint(ClockComponent.weather);
      paint(ClockComponent.analogTime);
    });
  }

  @override
  void debugPaint(PaintingContext context, Offset offset) {
    assert(() {
      if (debugPaintSizeEnabled) {
        final painter = TextPainter(
            text: const TextSpan(
                text:
                    'Please send me a sign :/ This is leading me nowhere and I do not mean this challenge - creativecreatorormaybenot.',
                style: TextStyle(
                    fontSize: 42,
                    color: Color(0xffff3456),
                    backgroundColor: Color(0xffffffff))),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
        painter.layout(maxWidth: size.width);
        painter.paint(context.canvas, Offset(0, size.height / 2));
      }
      return true;
    }());
  }
}

/// Takes care of validating [RenderObject]s passed to [CompositedClock] and assigning a [ClockComponent].
/// It also provides easy access to the [CompositedClockChildrenParentData] of this [RenderObject] via [compositedClockData].
abstract class RenderClockComponent extends RenderBox {
  final ClockComponent component;

  RenderClockComponent(
    this.component,
  ) : assert(component != null);

  CompositedClockChildrenParentData get compositedClockData =>
      parentData as CompositedClockChildrenParentData;

  /// Takes care of validating the RenderObject for when it is passed to [CompositedClock]
  /// and sets [CompositedClockChildrenParentData.child] to the appropriate [ClockComponent].
  /// Thus, this is annotated with [mustCallSuper]. Alternatively, you could ignore this and
  /// implement the validation and setting the component in the sub class, but the whole point of
  /// [RenderClockComponent] is to take care of this step, so you should likely extend [RenderBox] instead.
  @override
  @mustCallSuper
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositedClockData.valid = true;
    compositedClockData.child = component;
  }
}
