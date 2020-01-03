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
  final Map<ClockColor, Color> palette;

  AnimatedAnalogTime({
    Key key,
    @required this.animation,
    @required this.model,
    @required this.palette,
  })  : assert(animation != null),
        assert(model != null),
        assert(palette != null),
        super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final bounce = const HandBounceCurve().transform(animation.value), time = DateTime.now();

    return AnalogTime(
      secondHandAngle: // Regular distance
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
      textColor: palette[ClockColor.text],
      backgroundColor: palette[ClockColor.analogTimeBackground],
      backgroundHighlightColor: palette[ClockColor.analogTimeBackgroundHighlight],
      hourHandColor: palette[ClockColor.hourHand],
      minuteHandColor: palette[ClockColor.minuteHand],
      secondHandColor: palette[ClockColor.secondHand],
      shadowColor: palette[ClockColor.shadow],
    );
  }
}

class AnalogTime extends LeafRenderObjectWidget {
  final double secondHandAngle, minuteHandAngle, hourHandAngle;
  final int hourDivisions;

  final Color textColor, backgroundColor, backgroundHighlightColor, hourHandColor, minuteHandColor, secondHandColor, shadowColor;

  const AnalogTime({
    Key key,
    @required this.secondHandAngle,
    @required this.minuteHandAngle,
    @required this.hourHandAngle,
    @required this.hourDivisions,
    @required this.textColor,
    @required this.backgroundColor,
    @required this.backgroundHighlightColor,
    @required this.hourHandColor,
    @required this.minuteHandColor,
    @required this.secondHandColor,
    @required this.shadowColor,
  })  : assert(secondHandAngle != null),
        assert(minuteHandAngle != null),
        assert(hourHandAngle != null),
        assert(hourDivisions != null),
        assert(textColor != null),
        assert(backgroundColor != null),
        assert(backgroundHighlightColor != null),
        assert(hourHandColor != null),
        assert(minuteHandColor != null),
        assert(secondHandColor != null),
        assert(shadowColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnalogTime(
      secondHandAngle: secondHandAngle,
      minuteHandAngle: minuteHandAngle,
      hourHandAngle: hourHandAngle,
      hourDivisions: hourDivisions,
      textColor: textColor,
      backgroundColor: backgroundColor,
      backgroundHighlightColor: backgroundHighlightColor,
      hourHandColor: hourHandColor,
      minuteHandColor: minuteHandColor,
      secondHandColor: secondHandColor,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnalogTime renderObject) {
    renderObject
      ..secondHandAngle = secondHandAngle
      ..minuteHandAngle = minuteHandAngle
      ..hourHandAngle = hourHandAngle
      ..hourDivisions = hourDivisions
      ..textColor = textColor
      ..backgroundColor = backgroundColor
      ..backgroundHighlightColor = backgroundHighlightColor
      ..hourHandColor = hourHandColor
      ..minuteHandColor = minuteHandColor
      ..secondHandColor = secondHandColor
      ..shadowColor = shadowColor;
  }
}

class RenderAnalogTime extends RenderCompositionChild {
  RenderAnalogTime({
    double secondHandAngle,
    double minuteHandAngle,
    double hourHandAngle,
    int hourDivisions,
    Color textColor,
    Color backgroundColor,
    Color backgroundHighlightColor,
    Color hourHandColor,
    Color minuteHandColor,
    Color secondHandColor,
    Color shadowColor,
  })  : _secondHandAngle = secondHandAngle,
        _minuteHandAngle = minuteHandAngle,
        _hourHandAngle = hourHandAngle,
        _hourDivisions = hourDivisions,
        _textColor = textColor,
        _backgroundColor = backgroundColor,
        _backgroundHighlightColor = backgroundHighlightColor,
        _hourHandColor = hourHandColor,
        _minuteHandColor = minuteHandColor,
        _secondHandColor = secondHandColor,
        _shadowColor = shadowColor,
        super(ClockComponent.analogTime);

  double _secondHandAngle, _minuteHandAngle, _hourHandAngle;

  set secondHandAngle(double secondHandAngle) {
    if (_secondHandAngle != secondHandAngle) markNeedsPaint();

    _secondHandAngle = secondHandAngle;
  }

  set minuteHandAngle(double minuteHandAngle) {
    if (_minuteHandAngle != minuteHandAngle) markNeedsPaint();

    _minuteHandAngle = minuteHandAngle;
  }

  set hourHandAngle(double hourHandAngle) {
    if (_hourHandAngle != hourHandAngle) markNeedsPaint();

    _hourHandAngle = hourHandAngle;
  }

  int _hourDivisions;

  set hourDivisions(int hourDivisions) {
    if (_hourDivisions != hourDivisions) markNeedsPaint();

    _hourDivisions = hourDivisions;
  }

  Color _textColor, _backgroundColor, _backgroundHighlightColor, _hourHandColor, _minuteHandColor, _secondHandColor, _shadowColor;

  set textColor(Color textColor) {
    if (_textColor != textColor) markNeedsPaint();

    _textColor = textColor;
  }

  set backgroundColor(Color backgroundColor) {
    if (_backgroundColor != backgroundColor) markNeedsPaint();

    _backgroundColor = backgroundColor;
  }

  set backgroundHighlightColor(backgroundHighlightColor) {
    if (_backgroundHighlightColor != backgroundHighlightColor) markNeedsPaint();

    _backgroundHighlightColor = backgroundHighlightColor;
  }

  set hourHandColor(Color hourHandColor) {
    if (_hourHandColor != hourHandColor) markNeedsPaint();

    _hourHandColor = hourHandColor;
  }

  set minuteHandColor(Color minuteHandColor) {
    if (_minuteHandColor != minuteHandColor) markNeedsPaint();

    _minuteHandColor = minuteHandColor;
  }

  set secondHandColor(Color secondHandColor) {
    if (_secondHandColor != secondHandColor) markNeedsPaint();

    _secondHandColor = secondHandColor;
  }

  set shadowColor(Color shadowColor) {
    if (_shadowColor != shadowColor) markNeedsPaint();

    _shadowColor = shadowColor;
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

    final backgroundGradient = RadialGradient(
      colors: [
        _backgroundHighlightColor,
        _backgroundColor,
      ],
      stops: const [
        0,
        .7,
      ],
    ),
        fullCircleRect = Rect.fromCircle(center: Offset.zero, radius: _radius);

    canvas.drawOval(fullCircleRect, Paint()..shader = backgroundGradient.createShader(fullCircleRect));

    final largeDivisions = _hourDivisions, smallDivisions = 60;

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
              ..color = _textColor
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
            ..color = _textColor
            ..blendMode = BlendMode.darken);

      final painter = TextPainter(
        text: TextSpan(
          text: '$n',
          style: TextStyle(
            color: _textColor,
            fontSize: _radius / 8.2,
          ),
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

    // This is the order of the shadow elevations as well, i.e.
    // hour hand is located highest and the minute hand lowest.
    _drawMinuteHand(canvas);
    _drawSecondHand(canvas);
    _drawHourHand(canvas);

    canvas.restore();
  }

  void _drawHourHand(Canvas canvas) {
    canvas.save();

    canvas.rotate(_hourHandAngle);

    final paint = Paint()
          ..color = _hourHandColor
          ..style = PaintingStyle.fill,
        w = _radius / 42,
        h = -_radius / 2.29,
        bw = _radius / 6.3,
        bh = _radius / 7,
        path = Path()
          ..moveTo(0, 0)
          ..lineTo(-w / 2, 0)
          ..lineTo(-w / 2, h)
          ..quadraticBezierTo(
            -bw / 2,
            h - bh / 4,
            0,
            h - bh,
          )
          ..quadraticBezierTo(
            bw / 2,
            h - bh / 4,
            w / 2,
            h,
          )
          ..lineTo(w / 2, 0)
          ..close();

    canvas.drawPath(path, paint);

    // I have open questions about Canvas.drawShadow (see
    // https://github.com/flutter/flutter/issues/48027 and
    // https://stackoverflow.com/q/59549244/6509751).
    // I also just noticed that I opened that issue exactly on
    // New Year's first minute - was not on purpose, but this
    // should show something about my relationship to this project :)
    canvas.drawShadow(path, _shadowColor, _radius / 57, false);

    canvas.restore();
  }

  void _drawMinuteHand(Canvas canvas) {
    canvas.save();

    canvas.rotate(_minuteHandAngle);

    final paint = Paint()
          ..color = _minuteHandColor
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
    canvas.drawShadow(path, _shadowColor, _radius / 89, false);

    canvas.restore();
  }

  void _drawSecondHand(Canvas canvas) {
    canvas.save();
    // Second hand design parts: rotate in order to easily draw the parts facing straight up.
    canvas.transform(Matrix4.rotationZ(_secondHandAngle).storage);

    final paint = Paint()
          ..color = _secondHandColor
          ..style = PaintingStyle.fill,
        sh = -size.width / 4.7,
        eh = -size.width / 2.8,
        h = -size.width / 2.1,
        w = size.width / 205,
        lw = size.width / 71,
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

    canvas.drawPath(path, paint);
    canvas.drawShadow(path, _shadowColor, _radius / 64, false);

    canvas.restore();
  }
}
