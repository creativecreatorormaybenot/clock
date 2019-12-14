import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock/clock.dart';

const handBounceDuration = Duration(milliseconds: 274);

class AnimatedAnalogTime extends AnimatedWidget {
  final Animation<double> animation, layoutAnimation;
  final ClockModel model;

  AnimatedAnalogTime({
    Key key,
    @required this.animation,
    @required this.model,
    @required this.layoutAnimation,
  })  : assert(animation != null),
        assert(model != null),
        assert(layoutAnimation != null),
        super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final bounce = const HandBounceCurve().transform(animation.value),
        time = DateTime.now();

    return AnalogTime(
      layoutAnimation: layoutAnimation,
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
              pi *
                  2 /
                  (model.is24HourFormat ? 24 : 12) *
                  (model.is24HourFormat ? time.hour : time.hour % 12) +
              // Distance for the minute.
              pi * 2 / (model.is24HourFormat ? 24 : 12) / 60 * time.minute +
              // Distance for the second.
              pi * 2 / (model.is24HourFormat ? 24 : 12) / 60 / 60 * time.second,
      hourDivisions: model.is24HourFormat ? 24 : 12,
    );
  }
}

/// Curve describing the bouncing motion of the clock hands.
///
/// [ElasticOutCurve] already showed the overshoot beyond the destination position well,
/// however, the oscillation movement back to before the destination position was not pronounced enough.
/// Changing [ElasticOutCurve.period] to values greater than `0.4` will decrease how much the
/// curve oscillates as a whole, but I only wanted to decrease the magnitude of the first part
/// of the oscillation and increase the second to match real hand movement more closely,
/// hence, I created [HandBounceCurve].
///
/// I used this [slow motion capture of a watch](https://youtu.be/tyl7-gHRBX8?t=29) as a guide.
class HandBounceCurve extends Curve {
  const HandBounceCurve();

  @override
  double transformInternal(double t) {
    return troughTransform(elasticTransform(t));
  }

  double elasticTransform(double t) {
    final b = 12 / 27;
    return 1 + pow(2, -10 * t) * sin(((t - b / 4) * pi * 2) / b);
  }

  /// [Chris Drost helped me](https://math.stackexchange.com/a/3475134/569406) with this one.
  /// I have to say that I was mentally absent when reading through the solution for the first few times
  /// but figured it out eventually after coming back to it later. The result works fairly well.
  double troughTransform(double t) {
    return t * (1 - pow(e, pow(t, 12) * -5) * 4 / 9);
  }
}

class AnalogTime extends LeafRenderObjectWidget {
  final double secondHandAngle, minuteHandAngle, hourHandAngle;
  final TextStyle textStyle;
  final int hourDivisions;
  final Animation<double> layoutAnimation;

  const AnalogTime({
    Key key,
    @required this.textStyle,
    @required this.secondHandAngle,
    @required this.minuteHandAngle,
    @required this.hourHandAngle,
    @required this.hourDivisions,
    @required this.layoutAnimation,
  })  : assert(textStyle != null),
        assert(secondHandAngle != null),
        assert(minuteHandAngle != null),
        assert(hourHandAngle != null),
        assert(hourDivisions != null),
        assert(layoutAnimation != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnalogTime(
      textStyle: textStyle,
      secondHandAngle: secondHandAngle,
      minuteHandAngle: minuteHandAngle,
      hourHandAngle: hourHandAngle,
      hourDivisions: hourDivisions,
      layoutAnimation: layoutAnimation,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderAnalogTime renderObject) {
    renderObject
      ..textStyle = textStyle
      ..secondHandAngle = secondHandAngle
      ..minuteHandAngle = minuteHandAngle
      ..hourHandAngle = hourHandAngle
      ..hourDivisions = hourDivisions
      ..markNeedsPaint();
  }
}

class RenderAnalogTime extends RenderClockComponent {
  final Animation<double> layoutAnimation;

  RenderAnalogTime({
    this.textStyle,
    this.secondHandAngle,
    this.minuteHandAngle,
    this.hourHandAngle,
    this.hourDivisions,
    this.layoutAnimation,
  }) : super(ClockComponent.analogTime);

  double secondHandAngle, minuteHandAngle, hourHandAngle;
  TextStyle textStyle;
  int hourDivisions;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    layoutAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    layoutAnimation.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get sizedByParent => true;

  double _radius;

  @override
  void performResize() {
    size = constraints.biggest;

    _radius = size.height / 2;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    // Apply rotation as part of the CompositedClock layout animation.
    canvas.rotate(2 * pi * layoutAnimation.value);

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: _radius),
        Paint()..color = const Color(0xffffd345));

    final largeDivisions = hourDivisions, smallDivisions = 60;

    // Ticks indicating minutes and seconds (both 60).
    for (var n = smallDivisions; n > 0; n--) {
      // Do not draw small ticks when large ones will be drawn afterwards anyway.
      if (n % (smallDivisions / largeDivisions) != 0) {
        final height = 8.3;
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(0, (-size.width + height) / 2),
                width: 1.3,
                height: height),
            Paint()
              ..color = const Color(0xff000000)
              ..blendMode = BlendMode.darken);
      }

      canvas.rotate(-pi * 2 / smallDivisions);
    }

    // Ticks and numbers indicating hours.
    for (var n = largeDivisions; n > 0; n--) {
      final height = 4.2;
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(0, (-size.width + height) / 2),
              width: 3.1,
              height: height),
          Paint()
            ..color = const Color(0xff000000)
            ..blendMode = BlendMode.darken);

      final painter = TextPainter(
          text: TextSpan(text: '$n', style: textStyle),
          textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(
          canvas,
          Offset(
              -painter.width / 2,
              -size.height / 2 +
                  // Push the numbers inwards a bit.
                  9.6));

      canvas.rotate(-pi * 2 / largeDivisions);
    }

    // Hand displaying the current hour.
    canvas.drawLine(
        Offset.zero,
        Offset.fromDirection(hourHandAngle, size.width / 3.1),
        Paint()
          ..color = const Color(0xff000000)
          ..strokeWidth = 13.7
          ..strokeCap = StrokeCap.butt);

    // Hand displaying the current minute.
    canvas.drawLine(
        Offset.zero,
        Offset.fromDirection(minuteHandAngle, size.width / 2.3),
        Paint()
          ..color = const Color(0xff000000)
          ..strokeWidth = 8.4
          ..strokeCap = StrokeCap.square);

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
