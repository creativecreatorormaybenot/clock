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

    final canvas = context.canvas;

    canvas.save();
    // Translate to upper left corner of the clock's area.
    canvas.translate(offset.dx, offset.dy);

    // This path is supposed to represent a Bézier curve cutting the background colors.
    // It is supposed to be dynamically animated in order to convey a relaxed feeling.
    final s = weatherComponentRect.centerLeft, e = size.height / 2;
    final curve = Path()
      ..lineTo(s.dx, s.dy)
      // Curve about the left and bottom side of the weather component.
      ..quadraticBezierTo(
        weatherComponentRect.bottomLeft.dx,
        weatherComponentRect.bottomLeft.dy,
        weatherComponentRect.bottomCenter.dx,
        weatherComponentRect.bottomCenter.dy,
      )
      // Curve about the left side of the analog part to the bottom center of the analog part.
      ..cubicTo(
        analogComponentRect.centerLeft.dx,
        analogComponentRect.centerLeft.dy,
        analogComponentRect.bottomLeft.dx,
        analogComponentRect.bottomLeft.dy,
        analogComponentRect.bottomCenter.dx,
        analogComponentRect.bottomCenter.dy,
      )
      // Curve about the right side of the analog part to the end of the screen.
      ..cubicTo(
        analogComponentRect.bottomRight.dx,
        analogComponentRect.bottomRight.dy,
        analogComponentRect.centerRight.dx,
        analogComponentRect.centerRight.dy,
        size.width,
        e,
      );

    final upperPath = Path()
      ..moveTo(0, 0)
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
      ..moveTo(0, 0)
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
