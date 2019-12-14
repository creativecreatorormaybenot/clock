import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class BackgroundComponent extends LeafRenderObjectWidget {
  const BackgroundComponent({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBackgroundComponent();
  }
}

class RenderBackgroundComponent extends RenderClockComponent {
  RenderBackgroundComponent() : super(ClockComponent.background);

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // Do not need to clip here because CompositedClock already clips the canvas.

    final clockData = parentData as CompositedClockChildrenParentData, analogComponentRect = clockData.rectOf(ClockComponent.analogTime), weatherComponentRect = clockData.rectOf(ClockComponent.weather);

    final leftRect = () {
      double left, top;

      if (analogComponentRect.left < weatherComponentRect.left) {
        left = analogComponentRect.left;
        top = analogComponentRect.top;
      } else {
        left = weatherComponentRect.left;
        top = weatherComponentRect.top;
      }

      double right, bottom;

      if (analogComponentRect.right < weatherComponentRect.right) {
        right = analogComponentRect.right;
        bottom = analogComponentRect.bottom;
      } else {
        right = weatherComponentRect.right;
        bottom = weatherComponentRect.bottom;
      }

      return Rect.fromLTRB(left, top, right, bottom);
    }();

    final rightRect = () {
      double right, bottom;

      if (analogComponentRect.right > weatherComponentRect.right) {
        right = analogComponentRect.right;
        bottom = analogComponentRect.bottom;
      } else {
        right = weatherComponentRect.right;
        bottom = weatherComponentRect.bottom;
      }

      double left, top;

      if (analogComponentRect.left > weatherComponentRect.left) {
        left = analogComponentRect.left;
        top = analogComponentRect.top;
      } else {
        left = weatherComponentRect.left;
        top = weatherComponentRect.top;
      }

      return Rect.fromLTRB(left, top, right, bottom);
    }();

    final canvas = context.canvas;

    canvas.save();
    // Translate to upper left corner of the clock's area.
    canvas.translate(offset.dx, offset.dy);

    // This path is supposed to represent a Bézier curve cutting the background colors.
    // It is supposed to be dynamically animated in order to convey a relaxed feeling.
    final startHeight = lerpDouble(leftRect.centerLeft.dy, size.height / 2, 1 / 2),
        middleHeight = max(leftRect.bottom, rightRect.bottom),
        endHeight = lerpDouble(rightRect.centerLeft.dy, size.height / 2, 1 / 2);
    final curve = Path()
      ..moveTo(0, startHeight)
      ..cubicTo(
        leftRect.centerLeft.dx,
        startHeight,
        leftRect.bottomLeft.dx,
        leftRect.bottomLeft.dy,
        leftRect.bottomCenter.dx,
        leftRect.bottomCenter.dy,
      )
      ..cubicTo(
        leftRect.bottomRight.dx,
        leftRect.bottomRight.dy,
        leftRect.centerRight.dx,
        middleHeight,
        size.width / 2,
        middleHeight,
      )
      ..cubicTo(
        rightRect.centerLeft.dx,
        middleHeight,
        rightRect.bottomLeft.dx,
        rightRect.bottomLeft.dy,
        rightRect.bottomCenter.dx,
        rightRect.bottomCenter.dy,
      )
      ..cubicTo(
        rightRect.bottomRight.dx,
        rightRect.bottomRight.dy,
        rightRect.centerRight.dx,
        endHeight,
        size.width,
        endHeight,
      );

    final upperPath = Path()
      ..extendWithPath(curve, Offset.zero)
      // Line to top right, then top left, and then back to start to fill whole upper area.
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(
        upperPath,
        Paint()
          ..color = const Color(0xffffe312)
          ..style = PaintingStyle.fill);

    final lowerPath = Path()
      ..extendWithPath(curve, Offset.zero)
      // Line to bottom right, then bottom left, and then back to start to fill whole lower area.
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        lowerPath,
        Paint()
          ..color = const Color(0xffff4683)
          ..style = PaintingStyle.fill);

    canvas.restore();
  }
}
