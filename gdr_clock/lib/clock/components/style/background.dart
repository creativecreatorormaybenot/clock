import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

/// Making this component part of the [MultiChildRenderObjectWidget] ([CompositedClock]) allows
/// the background to react to the parts of the clock, i.e. it can draw based on the contents of the clock.
mixin BackgroundComponent on RenderBox, ContainerRenderObjectMixin<RenderBox, CompositedClockChildrenParentData>, RenderBoxContainerDefaultsMixin<RenderBox, CompositedClockChildrenParentData> {
  /// This draws the background but does not clip itself.
  /// The background is clipped in [RenderCompositedClock].
  void drawBackground(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate to upper left corner of the clock's area.
    canvas.translate(offset.dx, offset.dy);

    // This path is supposed to represent a Bézier curve cutting the background colors.
    // It is supposed to be dynamically animated in order to convey a relaxed feeling.
    final h = size.height / 2;
    final curve = Path()
      ..lineTo(0, h)
      ..cubicTo(size.width / 4, size.height / 3, size.width / 4, size.height * 2 / 3, size.width / 2, h)
      ..cubicTo(size.width * 3 / 4, size.height / 3, size.width * 3 / 4, size.height * 2 / 3, size.width, h)
      ..lineTo(size.width, h);

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
