import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class WeatherComponent extends LeafRenderObjectWidget {
  final List<String> conditions;
  final double handAngle;
  final TextStyle textStyle;

  WeatherComponent({
    Key key,
    @required this.conditions,
    @required this.handAngle,
    @required this.textStyle,
  })  : assert(conditions != null),
        assert(handAngle != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWeatherComponent(
      conditions: conditions,
      handAngle: handAngle,
      textStyle: textStyle,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderWeatherComponent renderObject) {
    renderObject
      ..conditions = conditions
      ..handAngle = handAngle
      ..textStyle = textStyle
      ..markNeedsPaint();
  }
}

class RenderWeatherComponent extends RenderClockComponent {
  RenderWeatherComponent({
    this.conditions,
    this.handAngle,
    this.textStyle,
  }) : super(ClockComponent.weather);

  List<String> conditions;
  double handAngle;
  TextStyle textStyle;

  @override
  bool get sizedByParent => true;

  double _radius;

  @override
  void performResize() {
    size = constraints.biggest;

    _radius = size.width / 2;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: _radius), Paint()..color = const Color(0xff3c9aff));

    final divisions = conditions.length;
    for (final condition in conditions) {
      final painter = TextPainter(text: TextSpan(text: '$condition', style: textStyle), textDirection: TextDirection.ltr);
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

    canvas.restore();
  }
}
