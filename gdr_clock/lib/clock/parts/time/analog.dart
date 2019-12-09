import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class AnalogPart extends LeafRenderObjectWidget {
  final double radius, handAngle;
  final TextStyle textStyle;

  const AnalogPart({
    @required this.radius,
    @required this.textStyle,
    @required this.handAngle,
  }) : assert(radius != null);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnalogPart(
      radius: radius,
      textStyle: textStyle,
      handAngle: handAngle,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnalogPart renderObject) {
    renderObject.update(
      radius: radius,
      textStyle: textStyle,
      handAngle: handAngle,
    );
  }
}

class RenderAnalogPart extends RenderClockPart {
  double radius, handAngle;
  TextStyle textStyle;

  RenderAnalogPart({
    this.radius,
    this.textStyle,
    this.handAngle,
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

  void update({double radius, TextStyle textStyle, double handAngle}) {
    this.radius = radius;
    this.textStyle = textStyle;
    this.handAngle = handAngle;

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

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: radius), Paint()..color = const Color(0xffffd345));

    final smallDivisions = 60, largeDivisions = 12;
    for (var n = smallDivisions; n > 0; n--) {
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: n % 12 == 0 ? 2.7 : 1.3, height: n % 12 == 0 ? 7.4 : 4.5),
          Paint()
            ..color = const Color(0xffffffff)
            ..blendMode = BlendMode.darken);

      canvas.rotate(-pi * 2 / smallDivisions);
    }

    for (var n = largeDivisions; n > 0; n--) {
      final painter = TextPainter(text: TextSpan(text: '$n', style: textStyle), textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(canvas, Offset(-painter.width / 2, -size.height / 2));

      canvas.rotate(-pi * 2 / largeDivisions);
    }

    canvas.drawLine(
        Offset.zero,
        Offset.fromDirection(handAngle, size.width / 2.1),
        Paint()
          ..color = const Color(0xff000000)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);

    canvas.restore();
  }
}
