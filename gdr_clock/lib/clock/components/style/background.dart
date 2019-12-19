import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class Background extends LeafRenderObjectWidget {
  const Background({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBackground();
  }
}

class RenderBackground extends RenderClockComponent {
  RenderBackground() : super(ClockComponent.background);

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // Do not need to clip here because CompositedClock already clips the canvas.

    final clockData = parentData as CompositedClockChildrenParentData, analogComponentRect = clockData.rectOf(ClockComponent.analogTime), weatherComponentRect = clockData.rectOf(ClockComponent.weather);

    final canvas = context.canvas;

    canvas.save();
    // Translate to upper left corner of the clock's area.
    canvas.translate(offset.dx, offset.dy);

    // This path is supposed to represent Bézier curves cutting the background colors.
    final curve = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);

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
