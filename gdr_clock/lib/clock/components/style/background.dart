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
    context.pushClipRect(needsCompositing, offset, Rect.fromLTWH(0, 0, size.width, size.height), (context, offset) {
      final canvas = context.canvas;

      canvas.save();
      // Translate to upper left corner of the clock's area.
      canvas.translate(offset.dx, offset.dy);

      // This path is supposed to represent a Bézier curve cutting the background colors.
      // It is supposed to be dynamically animated in order to convey a relaxed feeling.
      final curve = Path();



      canvas.drawPath(curve, Paint()..color = const Color(0xffff46d3)..style = PaintingStyle.fill);

      canvas.restore();
    });
  }
}
