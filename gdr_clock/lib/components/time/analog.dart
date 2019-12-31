import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';

const handBounceDuration = Duration(milliseconds: 274);

class AnimatedAnalogTime extends AnimatedWidget {
  final Animation<double> animation;
  final ClockModel model;

  AnimatedAnalogTime({
    Key key,
    @required this.animation,
    @required this.model,
  })  : assert(animation != null),
        assert(model != null),
        super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final bounce = const HandBounceCurve().transform(animation.value), time = DateTime.now();

    return AnalogTime(
      textStyle: Theme.of(context).textTheme.display1,
      secondHandAngle:
          // Regular distance
          pi * 2 / 60 * time.second +
              // Bounce
              pi * 2 / 60 * (bounce - 1),
      minuteHandAngle: pi * 2 / 60 * time.minute +
          // Bounce only when the minute changes.
          (time.second != 0 ? 0 : pi * 2 / 60 * (bounce - 1)),
      hourHandAngle:
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

  const AnalogTime({
    Key key,
    @required this.textStyle,
    @required this.secondHandAngle,
    @required this.minuteHandAngle,
    @required this.hourHandAngle,
    @required this.hourDivisions,
  })  : assert(textStyle != null),
        assert(secondHandAngle != null),
        assert(minuteHandAngle != null),
        assert(hourHandAngle != null),
        assert(hourDivisions != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnalogTime(
      textStyle: textStyle,
      secondHandAngle: secondHandAngle,
      minuteHandAngle: minuteHandAngle,
      hourHandAngle: hourHandAngle,
      hourDivisions: hourDivisions,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnalogTime renderObject) {
    renderObject
      ..textStyle = textStyle
      ..secondHandAngle = secondHandAngle
      ..minuteHandAngle = minuteHandAngle
      ..hourHandAngle = hourHandAngle
      ..hourDivisions = hourDivisions
      ..markNeedsPaint();
  }
}

class RenderAnalogTime extends RenderCompositionChild {
  RenderAnalogTime({
    this.textStyle,
    this.secondHandAngle,
    this.minuteHandAngle,
    this.hourHandAngle,
    this.hourDivisions,
  }) : super(ClockComponent.analogTime);

  double secondHandAngle, minuteHandAngle, hourHandAngle;
  TextStyle textStyle;
  int hourDivisions;

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

    const backgroundGradient = RadialGradient(colors: [
      Color(0xffffffff),
      Color(0xffeaffd8),
    ], stops: [
      0,
      .7,
    ]);
    final fullCircleRect = Rect.fromCircle(center: Offset.zero, radius: _radius);

    canvas.drawOval(fullCircleRect, Paint()..shader = backgroundGradient.createShader(fullCircleRect));

    final largeDivisions = hourDivisions, smallDivisions = 60;

    // Ticks indicating minutes and seconds (both 60).
    for (var n = smallDivisions; n > 0; n--) {
      // Do not draw small ticks when large ones will be drawn afterwards anyway.
      if (n % (smallDivisions / largeDivisions) != 0) {
        final height = _radius / 31;
        canvas.drawRect(
            Rect.fromCenter(
              center: Offset(0, (-size.width + height) / 2),
              width: _radius / 195,
              height: height,
            ),
            Paint()
              ..color = const Color(0xff000000)
              ..blendMode = BlendMode.darken);
      }

      // This will go back to 0 at the end of loop,
      // i.e. at `-pi * 2` which is rendered as the same.
      canvas.rotate(-pi * 2 / smallDivisions);
    }

    // Ticks and numbers indicating hours.
    for (var n = largeDivisions; n > 0; n--) {
      final height = _radius / 65;
      canvas.drawRect(
          Rect.fromCenter(
            center: Offset(0, (-size.width + height) / 2),
            width: _radius / 86,
            height: height,
          ),
          Paint()
            ..color = const Color(0xff000000)
            ..blendMode = BlendMode.darken);

      final painter = TextPainter(
        text: TextSpan(
          text: '$n',
          style: textStyle.copyWith(fontSize: _radius / 8.2),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      painter.paint(
          canvas,
          Offset(
            -painter.width / 2,
            -size.height / 2 +
                // Push the numbers inwards a bit.
                _radius / 24,
          ));

      // Like above, this will go back to 0 at the end of loop,
      // i.e. at `-pi * 2` which is rendered as the same.
      canvas.rotate(-pi * 2 / largeDivisions);
    }

    canvas.drawPetals(_radius);

    _drawHourHand(canvas);
    _drawMinuteHand(canvas);
    _drawSecondHand(canvas);

    canvas.restore();
  }

  void _drawHourHand(Canvas canvas) {
    canvas.save();

    canvas.rotate(hourHandAngle);

    final paint = Paint()
          ..color = const Color(0xff000000)
          ..style = PaintingStyle.fill,
        w = _radius / 19,
        h = -size.width / 3.1,
        path = Path()
          ..moveTo(0, 0)
          ..lineTo(-w / 2, 0)
          ..lineTo(-w / 2, h)
          ..lineTo(w / 2, h)
          ..lineTo(w / 2, 0)
          ..close();

    canvas.drawPath(path, paint);

    canvas.restore();
  }

  void _drawMinuteHand(Canvas canvas) {
    canvas.save();

    canvas.rotate(minuteHandAngle);

    final paint = Paint()
          ..color = const Color(0xff000000)
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
        h = -_radius / 1.15,
        w = _radius / 18,
        path = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(
            -w,
            h / 4,
            0,
            h,
          )
          ..quadraticBezierTo(
            w,
            h / 4,
            0,
            0,
          )
          ..close();

    canvas.drawPath(path, paint);

    canvas.drawShadow(path, const Color(0xff000000), _radius / 12, false);

    canvas.restore();
  }

  void _drawSecondHand(Canvas canvas) {
    canvas.save();
    // Second hand design parts: rotate in order to easily draw the parts facing straight up.
    canvas.transform(Matrix4.rotationZ(secondHandAngle).storage);

    final sh = -size.width / 4.7,
        eh = -size.width / 2.8,
        h = -size.width / 2.1,
        w = size.width / 121,
        lw = size.width / 42,
        path = Path()
          ..moveTo(0, 0)
          ..lineTo(-w / 2, 0)
          ..lineTo(-w / 2, sh)
          ..lineTo(w / 2, sh)
          ..lineTo(w / 2, 0)
          ..close()
          // Left side of the design part in the middle
          ..moveTo(-w / 2, sh)
          ..lineTo(-lw / 2, sh)
          ..lineTo(-lw / 2, eh)
          ..lineTo(-w / 2, eh)
          ..close()
          // Other side of the part
          ..moveTo(w / 2, sh)
          ..lineTo(lw / 2, sh)
          ..lineTo(lw / 2, eh)
          ..lineTo(w / 2, eh)
          ..close()
          // End of hand
          ..moveTo(-w / 2, eh)
          ..lineTo(-w / 2, h)
          ..lineTo(w / 2, h)
          ..lineTo(w / 2, eh)
          ..close();

    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xff000000)
          ..style = PaintingStyle.fill);

//    canvas.drawShadow(path, const Color(0xff000000), _radius / 12, false);

    canvas.restore();
  }
}
