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

      // todo temporary background
      canvas.drawPaint(Paint()..color = const Color(0xffff46d3));

      // todo draw background separated by curve

      canvas.restore();
    });
  }
}
