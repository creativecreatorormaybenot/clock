import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class Slide extends LeafRenderObjectWidget {
  final Color curveColor;

  Slide({
    Key key,
    @required this.curveColor,
  })  : assert(curveColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSlide(
      curveColor: curveColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSlide renderObject) {
    renderObject..curveColor = curveColor;
  }
}

class RenderSlide extends RenderCompositionChild {
  RenderSlide({
    Color curveColor,
  })  : _curveColor = curveColor,
        super(ClockComponent.slide);

  Color _curveColor;

  set curveColor(Color curveColor) {
    if (_curveColor != curveColor) markNeedsPaint();

    _curveColor = curveColor;
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final area = Offset.zero & size;

    canvas.drawLine(
        area.topRight,
        area.bottomLeft,
        Paint()
          ..color = _curveColor
          ..strokeWidth = area.shortestSide / 35);

    canvas.restore();
  }
}
