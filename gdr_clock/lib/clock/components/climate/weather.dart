import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class Weather extends LeafRenderObjectWidget {
  final List<String> conditions;
  final double angle;
  final TextStyle textStyle;

  Weather({
    Key key,
    @required this.conditions,
    @required this.angle,
    @required this.textStyle,
  })  : assert(conditions != null),
        assert(angle != null),
        assert(textStyle != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWeather(
        conditions: conditions, angle: angle, textStyle: textStyle);
  }

  @override
  void updateRenderObject(BuildContext context, RenderWeather renderObject) {
    renderObject
      ..conditions = conditions
      ..angle = angle
      ..textStyle = textStyle
      ..markNeedsPaint();
  }
}

class RenderWeather extends RenderClockComponent {
  RenderWeather({
    this.conditions,
    this.angle,
    this.textStyle,
  }) : super(ClockComponent.weather);

  List<String> conditions;
  double angle;
  TextStyle textStyle;

  @override
  bool get sizedByParent => true;

  double _radius;

  @override
  void performResize() {
    size = constraints.biggest;

    _radius = size.width / 2;
  }

  static const arrowColor = Color(0xffffddbb);

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: _radius),
        Paint()..color = const Color(0xff3c9aff));

    final divisions = conditions.length;
    for (final condition in conditions) {
      final painter = TextPainter(
          text: TextSpan(text: '$condition', style: textStyle),
          textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(
          canvas,
          Offset(
              -painter.width / 2,
              -size.height / 2 +
                  // Push the text inwards a bit.
                  9.6));

      canvas.rotate(2 * pi / divisions);
    }

    // Draw tip of the arrow pointing up.
    final h = -size.height / 3.4, s = 13.42;
    canvas.drawPath(
        Path()
          // Remember that this is the center of the circle.
          ..moveTo(0, h)
          ..lineTo(-s, h)
          ..lineTo(0, h - s)
          ..lineTo(s, h)
          ..lineTo(0, h)
          ..close(),
        Paint()
          ..color = arrowColor
          ..style = PaintingStyle.fill);
    // Draw the rest of the arrow.
    canvas.drawLine(
        Offset.zero,
        Offset(0, h),
        Paint()
          ..color = arrowColor
          ..strokeWidth = 5.2
          ..strokeCap = StrokeCap.round);

    canvas.restore();
  }
}
