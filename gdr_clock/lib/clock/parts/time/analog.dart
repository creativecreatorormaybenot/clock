import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class AnalogPart extends LeafRenderObjectWidget {
  final double radius, pointerAngle;
  final TextStyle textStyle;

  const AnalogPart({
    @required this.radius,
    @required this.textStyle,
    @required this.pointerAngle,
  }) : assert(radius != null);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnalogPart(
      radius: radius,
      textStyle: textStyle,
      pointerAngle: pointerAngle,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnalogPart renderObject) {
    renderObject.update(
      radius: radius,
      textStyle: textStyle,
      pointerAngle: pointerAngle,
    );
  }
}

class RenderAnalogPart extends RenderClockPart {
  double radius, pointerAngle;
  TextStyle textStyle;

  RenderAnalogPart({
    this.radius,
    this.textStyle,
    this.pointerAngle,
  }) : super(ClockComponent.analogTime);

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // (for formatting reasons)
  }

  @override
  void detach() {
    // (for formatting reasons)
    super.detach();
  }

  void update({double radius, TextStyle textStyle, double pointerAngle}) {
    this.radius = radius;
    this.textStyle = textStyle;
    this.pointerAngle = pointerAngle;

    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = Size.fromRadius(radius);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: radius), Paint()..color = Color(0xffffd345));

    final divisions = 12;
    canvas.rotate(pi * 2 / divisions);

    for (var n = divisions; n > 0; n--) {
      canvas.rotate(-pi * 2 / divisions);

      final painter = TextPainter(text: TextSpan(text: '$n', style: textStyle), textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(canvas, Offset(-painter.width / 2, -size.height / 2));
    }

    canvas.drawLine(
        Offset.zero,
        Offset.fromDirection(pointerAngle, size.width / 2.1),
        Paint()
          ..color = Color(0xff000000)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);

    canvas.restore();
  }
}
