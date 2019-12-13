import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class BackgroundComponent extends LeafRenderObjectWidget {
  BackgroundComponent({Key key}) : super(key: key);

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
    final clockData = parentData as CompositedClockChildrenParentData;

    final analogComponentOffset = clockData.offsetOf(ClockComponent.analogTime), analogComponentSize = clockData.sizeOf(ClockComponent.analogTime);

    context.pushClipRect(needsCompositing, offset, Rect.fromLTWH(0, 0, size.width, size.height), (context, offset) {
      final canvas = context.canvas;

      canvas.save();
      // Translate to upper left corner of the clock's area.
      canvas.translate(offset.dx, offset.dy);

      // This path is supposed to represent a Bézier curve cutting the background colors.
      // It is supposed to be dynamically animated in order to convey a relaxed feeling.
      final s = size.height / 2, e = size.height / 2;
      final curve = Path()
        ..lineTo(0, s)
        // Curve abound the left side of the analog part to the bottom center of the analog part.
        ..cubicTo(analogComponentOffset.dx, analogComponentOffset.dy + analogComponentSize.height / 2, analogComponentOffset.dx, analogComponentOffset.dy + analogComponentSize.height,
            analogComponentOffset.dx + analogComponentSize.width / 2, analogComponentOffset.dy + analogComponentSize.height)
        // Curve abound the right side of the analog part to the end of the screen.
        ..cubicTo(analogComponentOffset.dx + analogComponentSize.width, analogComponentOffset.dy + analogComponentSize.height, analogComponentOffset.dx + analogComponentSize.width,
            analogComponentOffset.dy + analogComponentSize.height / 2, size.width, e);

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
    });
  }
}
