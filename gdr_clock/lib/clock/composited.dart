import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CompositedClock extends MultiChildRenderObjectWidget {
  CompositedClock({
    Key key,
  }) : super(key: key, children: []);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCompositedClock();
  }
}

class CompositedClockChildrenParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCompositedClock extends RenderBox with ContainerRenderObjectMixin<RenderBox, CompositedClockChildrenParentData>, RenderBoxContainerDefaultsMixin<RenderBox, CompositedClockChildrenParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! CompositedClockChildrenParentData) child.parentData = CompositedClockChildrenParentData();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void debugPaint(PaintingContext context, Offset offset) {
    assert(() {
      if (debugPaintSizeEnabled) {
        final painter = TextPainter(
            text: TextSpan(text: 'Please send me a sign :/ This is leading me nowhere and I do not mean this challenge - creativecreatorormaybenot.', style: TextStyle(fontSize: 42, color: Color(0xffff3456))),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
        painter.layout(maxWidth: size.width);
        painter.paint(context.canvas, Offset(0, size.height / 2));
      }
      return true;
    }());
  }
}
