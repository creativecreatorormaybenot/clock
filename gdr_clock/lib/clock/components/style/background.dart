import 'dart:math';
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

    final leftCenterLeft = analogComponentRect.left < weatherComponentRect.left ? analogComponentRect.centerLeft : weatherComponentRect.centerLeft,
        leftBottomLeft = analogComponentRect.left < weatherComponentRect.left ? analogComponentRect.bottomLeft : weatherComponentRect.bottomLeft,
        leftBottomCenter = analogComponentRect.bottomCenter.dx < weatherComponentRect.bottomCenter.dx ? analogComponentRect.bottomCenter : weatherComponentRect.bottomCenter,
        leftBottomRight = analogComponentRect.right < weatherComponentRect.right ? analogComponentRect.bottomRight : weatherComponentRect.bottomRight,
        rightBottomLeft = analogComponentRect.bottomLeft.dx > weatherComponentRect.bottomLeft.dx ? analogComponentRect.bottomLeft : weatherComponentRect.bottomLeft,
        rightBottomCenter = analogComponentRect.bottomCenter.dx > weatherComponentRect.bottomCenter.dx ? analogComponentRect.bottomCenter : weatherComponentRect.bottomCenter,
        rightBottomRight = analogComponentRect.right > weatherComponentRect.right ? analogComponentRect.bottomRight : weatherComponentRect.bottomRight,
        rightCenterRight = analogComponentRect.right > weatherComponentRect.right ? analogComponentRect.centerRight : weatherComponentRect.centerLeft,
        leftCenterRightX = leftBottomRight.dx,
        rightCenterLeftX = rightBottomLeft.dx;

    final canvas = context.canvas;

    canvas.save();
    // Translate to upper left corner of the clock's area.
    canvas.translate(offset.dx, offset.dy);

    // This path is supposed to represent a Bézier curve cutting the background colors.
    // It is supposed to be dynamically animated in order to convey a relaxing feeling.
    final startHeight = lerpDouble(leftCenterLeft.dy, size.height / 2, 1 / 2),
        middleHeight = max(analogComponentRect.bottom, weatherComponentRect.bottom),
        endHeight = lerpDouble(rightCenterRight.dy, size.height / 2, 1 / 2);
    final curve = Path()
      ..moveTo(0, startHeight)
      ..cubicTo(
        leftCenterLeft.dx,
        startHeight,
        leftBottomLeft.dx,
        leftBottomLeft.dy,
        leftBottomCenter.dx,
        leftBottomCenter.dy,
      )
      ..cubicTo(
        leftBottomRight.dx,
        leftBottomRight.dy,
        leftCenterRightX,
        middleHeight,
        size.width / 2,
        middleHeight,
      )
      ..cubicTo(
        rightCenterLeftX,
        middleHeight,
        rightBottomLeft.dx,
        rightBottomLeft.dy,
        rightBottomCenter.dx,
        rightBottomCenter.dy,
      )
      ..cubicTo(
        rightBottomRight.dx,
        rightBottomRight.dy,
        rightCenterRight.dx,
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
