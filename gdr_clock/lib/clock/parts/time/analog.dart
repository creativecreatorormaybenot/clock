import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock/clock.dart';

class AnimatedAnalogPart extends AnimatedWidget {
  final Animation<double> handBounce;
  final DateTime time;
  final ClockModel model;
  final double radius;

  AnimatedAnalogPart({
    Key key,
    @required this.handBounce,
    @required this.time,
    @required this.radius,
    @required this.model,
  }): assert(handBounce != null), assert(time != null), assert(radius != null), assert(model != null), super(key: key, listenable: handBounce);

  @override
  Widget build(BuildContext context) {
    final bounce = Curves.bounceOut.transform(handBounce.value);
    return AnalogPart(
      radius: radius,
      textStyle: Theme.of(context).textTheme.display1,
      secondHandAngle: -pi / 2 +
          // Regular distance
          pi * 2 / 60 * time.second +
          // Bounce
          pi * 2 / 60 * (bounce - 1),
      minuteHandAngle: -pi / 2 +
          pi * 2 / 60 * time.minute +
          // Bounce only when the minute changes.
          (time.second != 0 ? 0 : pi * 2 / 60 * (bounce - 1)),
      hourHandAngle:
      // Angle equal to 0 starts on the right side and not on the top.
      -pi / 2 +
          // Distance for the hour.
          pi * 2 / (model.is24HourFormat ? 24 : 12) * (model.is24HourFormat ? time.hour : time.hour % 12) +
          // Distance for the minute.
          pi * 2 / (model.is24HourFormat ? 24 : 12) / 60 * time.minute +
          // Distance for the second.
          pi * 2 / (model.is24HourFormat ? 24 : 12) / 60 / 60 * time.second,
      hourDivisions: model.is24HourFormat ? 24 : 12,
    );
  }
}

class AnalogPart extends LeafRenderObjectWidget {
  final double radius, secondHandAngle, minuteHandAngle, hourHandAngle;
  final TextStyle textStyle;
  final int hourDivisions;

  const AnalogPart({
    Key key,
    @required this.radius,
    @required this.textStyle,
    @required this.secondHandAngle,
    @required this.minuteHandAngle,
    @required this.hourHandAngle,
    @required this.hourDivisions,
  }) : assert(radius != null), super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnalogPart(
      radius: radius,
      textStyle: textStyle,
      secondHandAngle: secondHandAngle,
      minuteHandAngle: minuteHandAngle,
      hourHandAngle: hourHandAngle,
      hourDivisions: hourDivisions,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnalogPart renderObject) {
    renderObject.update(
      radius: radius,
      textStyle: textStyle,
      secondHandAngle: secondHandAngle,
      minuteHandAngle: minuteHandAngle,
      hourHandAngle: hourHandAngle,
      hourDivisions: hourDivisions,
    );
  }
}

class RenderAnalogPart extends RenderClockPart {
  double radius, secondHandAngle, minuteHandAngle, hourHandAngle;
  TextStyle textStyle;
  int hourDivisions;

  RenderAnalogPart({
    this.radius,
    this.textStyle,
    this.secondHandAngle,
    this.minuteHandAngle,
    this.hourHandAngle,
    this.hourDivisions,
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

  void update({
    double radius,
    TextStyle textStyle,
    double secondHandAngle,
    double minuteHandAngle,
    double hourHandAngle,
    int hourDivisions,
  }) {
    this.radius = radius;
    this.textStyle = textStyle;
    this.secondHandAngle = secondHandAngle;
    this.minuteHandAngle = minuteHandAngle;
    this.hourHandAngle = hourHandAngle;
    this.hourDivisions = hourDivisions;

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
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: radius), Paint()..color = const Color(0xffffd345));

    final largeDivisions = hourDivisions, smallDivisions = 60;
    for (var n = smallDivisions; n > 0; n--) {
      // Do not draw small ticks when large ones will be drawn afterwards anyway.
      if (n % (smallDivisions / largeDivisions) != 0) {
        final height = 4.5;
        canvas.drawRect(
            Rect.fromCenter(center: Offset(0, (-size.width + height) / 2), width: 1.3, height: height),
            Paint()
              ..color = const Color(0xff000000)
              ..blendMode = BlendMode.darken);
      }

      canvas.rotate(-pi * 2 / smallDivisions);
    }

    for (var n = largeDivisions; n > 0; n--) {
      final height = 7.9;
      canvas.drawRect(
          Rect.fromCenter(center: Offset(0, (-size.width + height) / 2), width: 2.3, height: height),
          Paint()
            ..color = const Color(0xff000000)
            ..blendMode = BlendMode.darken);

      final painter = TextPainter(text: TextSpan(text: '$n', style: textStyle), textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(canvas, Offset(-painter.width / 2, -size.height / 2 + 6.2));

      canvas.rotate(-pi * 2 / largeDivisions);
    }

    // Hand displaying the current hour.
    canvas.drawLine(
        Offset.zero,
        Offset.fromDirection(hourHandAngle, size.width / 3.1),
        Paint()
          ..color = const Color(0xff000000)
          ..strokeWidth = 13.7
          ..strokeCap = StrokeCap.square);

    // Hand displaying the current minute.
    canvas.drawLine(
        Offset.zero,
        Offset.fromDirection(minuteHandAngle, size.width / 2.3),
        Paint()
          ..color = const Color(0xff000000)
          ..strokeWidth = 8.4
          ..strokeCap = StrokeCap.round);

    // Hand displaying the current second.
    canvas.drawLine(
        Offset.zero,
        Offset.fromDirection(secondHandAngle, size.width / 2.1),
        Paint()
          ..color = const Color(0xff000000)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);

    canvas.restore();
  }
}
