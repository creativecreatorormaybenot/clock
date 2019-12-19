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

    final clockData = parentData as CompositedClockChildrenParentData;

    final gooArea = Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2);
    final componentAreaInGoo = [clockData.rectOf(ClockComponent.analogTime), clockData.rectOf(ClockComponent.weather)].map((rect) => rect.intersect(gooArea));

    final canvas = context.canvas;

    canvas.save();
    // Translate to upper left corner of the clock's area.
    canvas.translate(offset.dx, offset.dy);

    // This path is supposed to represent the goo being indented by the components, which is achieved by adding Bézier curves.
    final cut = Path()..moveTo(0, size.height / 2);

    const margin = 13.0;

    for (final rect in componentAreaInGoo) {
      canvas.drawRect(rect, Paint()..color = Color(0xff000000));
      cut
        ..lineTo(
          rect.left - margin,
          gooArea.top,
        )
        ..cubicTo(
          rect.topLeft.dx,
          rect.topLeft.dy,
          rect.bottomLeft.dx,
          rect.bottomLeft.dy,
          rect.bottomCenter.dx,
          rect.bottomCenter.dy,
        )
        ..cubicTo(
          rect.bottomRight.dx,
          rect.bottomRight.dy,
          rect.topRight.dx,
          rect.topRight.dy,
          rect.right + margin,
          gooArea.top,
        );
    }

    cut.lineTo(size.width, gooArea.top);

    canvas.drawRect(gooArea, Paint()..color = const Color(0xffffa3f4));

//    final upperPath = Path()
//      ..extendWithPath(cut, Offset.zero)
//      // Line to top right, then top left, and then back to start to fill whole upper area.
//      ..lineTo(size.width, 0)
//      ..lineTo(0, 0)
//      ..close();
//    canvas.drawPath(
//        upperPath,
//        Paint()
//          ..color = const Color(0xffffe312)
//          ..style = PaintingStyle.fill);
//
//    final lowerPath = Path()
//      ..extendWithPath(cut, Offset.zero)
//      // Line to bottom right, then bottom left, and then back to start to fill whole lower area.
//      ..lineTo(size.width, size.height)
//      ..lineTo(0, size.height)
//      ..close();
//    canvas.drawPath(
//        lowerPath,
//        Paint()
//          ..color = const Color(0xffff4683)
//          ..style = PaintingStyle.fill);

    canvas.restore();
  }
}
