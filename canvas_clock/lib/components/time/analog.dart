import 'dart:math';
import 'dart:ui' as ui;

import 'package:canvas_clock/clock.dart';
import 'package:canvas_clock/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

const handBounceDuration = Duration(milliseconds: 274);

class AnimatedAnalogTime extends AnimatedWidget {
  final Animation<double> animation, bounceAnimation;

  final ClockModel model;
  final Map<ClockColor, Color> palette;

  AnimatedAnalogTime({
    Key key,
    @required this.animation,
    @required this.bounceAnimation,
    @required this.model,
    @required this.palette,
  })  : assert(animation != null),
        assert(bounceAnimation != null),
        assert(model != null),
        assert(palette != null),
        super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final bounce = const HandBounceCurve().transform(animation.value),
        time = DateTime.now();

    return AnalogTime(
      bounceAnimation: bounceAnimation,
      secondHandAngle: // Regular distance
          pi * 2 / 60 * time.second +
              // Bounce
              pi * 2 / 60 * (bounce - 1),
      minuteHandAngle: pi * 2 / 60 * time.minute +
          // Bounce only when the minute changes.
          (time.second != 0 ? 0 : pi * 2 / 60 * (bounce - 1)),
      hourHandAngle:
          // Distance for the hour.
          pi * 2 / 12 * (time.hour % 12) +
              // Distance for the minute.
              pi * 2 / 12 / 60 * time.minute +
              // Distance for the second.
              pi * 2 / 12 / 60 / 60 * time.second,
      use24HourFormat: model.is24HourFormat,
      ballEvery: ballEvery,
      textColor: palette[ClockColor.text],
      backgroundColor: palette[ClockColor.analogTimeBackground],
      backgroundHighlightColor:
          palette[ClockColor.analogTimeBackgroundHighlight],
      hourHandColor: palette[ClockColor.hourHand],
      minuteHandColor: palette[ClockColor.minuteHand],
      secondHandColor: palette[ClockColor.secondHand],
      shadowColor: palette[ClockColor.shadow],
      borderColor: palette[ClockColor.border],
      petalsColor: palette[ClockColor.petals],
      petalsHighlightColor: palette[ClockColor.petalsHighlight],
    );
  }
}

class AnalogTime extends LeafRenderObjectWidget {
  final Animation<double> bounceAnimation;

  final double secondHandAngle, minuteHandAngle, hourHandAngle;

  final bool use24HourFormat;

  /// This dictates where the ball icon will be drawn.
  ///
  /// `60` has to be evenly divisible by [ballEvery]
  /// because otherwise it is not clear where ball
  /// icons should be drawn.
  ///
  /// For example, if this is `30`, there will be a ball
  /// icon drawn at `θ = 0` and one at `θ = π`.
  final int ballEvery;

  final Color textColor,
      backgroundColor,
      backgroundHighlightColor,
      hourHandColor,
      minuteHandColor,
      secondHandColor,
      shadowColor,
      borderColor,
      petalsColor,
      petalsHighlightColor;

  const AnalogTime({
    Key key,
    @required this.bounceAnimation,
    @required this.secondHandAngle,
    @required this.minuteHandAngle,
    @required this.hourHandAngle,
    @required this.use24HourFormat,
    @required this.ballEvery,
    @required this.textColor,
    @required this.backgroundColor,
    @required this.backgroundHighlightColor,
    @required this.hourHandColor,
    @required this.minuteHandColor,
    @required this.secondHandColor,
    @required this.shadowColor,
    @required this.borderColor,
    @required this.petalsColor,
    @required this.petalsHighlightColor,
  })  : assert(bounceAnimation != null),
        assert(secondHandAngle != null),
        assert(minuteHandAngle != null),
        assert(hourHandAngle != null),
        assert(use24HourFormat != null),
        assert(ballEvery != null),
        assert(textColor != null),
        assert(backgroundColor != null),
        assert(backgroundHighlightColor != null),
        assert(hourHandColor != null),
        assert(minuteHandColor != null),
        assert(secondHandColor != null),
        assert(shadowColor != null),
        assert(borderColor != null),
        assert(petalsColor != null),
        assert(petalsHighlightColor != null),
        assert(60 % ballEvery == 0),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnalogTime(
      bounceAnimation: bounceAnimation,
      secondHandAngle: secondHandAngle,
      minuteHandAngle: minuteHandAngle,
      hourHandAngle: hourHandAngle,
      use24HourFormat: use24HourFormat,
      ballEvery: ballEvery,
      textColor: textColor,
      backgroundColor: backgroundColor,
      backgroundHighlightColor: backgroundHighlightColor,
      hourHandColor: hourHandColor,
      minuteHandColor: minuteHandColor,
      secondHandColor: secondHandColor,
      shadowColor: shadowColor,
      borderColor: borderColor,
      petalsColor: petalsColor,
      petalsHighlightColor: petalsHighlightColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAnalogTime renderObject) {
    renderObject
      ..secondHandAngle = secondHandAngle
      ..minuteHandAngle = minuteHandAngle
      ..hourHandAngle = hourHandAngle
      ..use24HourFormat = use24HourFormat
      ..ballEvery = ballEvery
      ..textColor = textColor
      ..backgroundColor = backgroundColor
      ..backgroundHighlightColor = backgroundHighlightColor
      ..hourHandColor = hourHandColor
      ..minuteHandColor = minuteHandColor
      ..secondHandColor = secondHandColor
      ..shadowColor = shadowColor
      ..borderColor = borderColor
      ..petalsColor = petalsColor
      ..petalsHighlightColor = petalsHighlightColor;
  }
}

class AnalogTimeParentData extends ClockChildrenParentData {
  Offset bounce;
}

class RenderAnalogTime
    extends RenderCompositionChild<ClockComponent, AnalogTimeParentData> {
  final Animation<double> bounceAnimation;

  RenderAnalogTime({
    this.bounceAnimation,
    double secondHandAngle,
    double minuteHandAngle,
    double hourHandAngle,
    bool use24HourFormat,
    int ballEvery,
    Color textColor,
    Color backgroundColor,
    Color backgroundHighlightColor,
    Color hourHandColor,
    Color minuteHandColor,
    Color secondHandColor,
    Color shadowColor,
    Color borderColor,
    Color petalsColor,
    Color petalsHighlightColor,
  })  : _secondHandAngle = secondHandAngle,
        _minuteHandAngle = minuteHandAngle,
        _hourHandAngle = hourHandAngle,
        _use24HourFormat = use24HourFormat,
        _ballEvery = ballEvery,
        _textColor = textColor,
        _backgroundColor = backgroundColor,
        _backgroundHighlightColor = backgroundHighlightColor,
        _hourHandColor = hourHandColor,
        _minuteHandColor = minuteHandColor,
        _secondHandColor = secondHandColor,
        _shadowColor = shadowColor,
        _borderColor = borderColor,
        _petalsColor = petalsColor,
        _petalsHighlightColor = petalsHighlightColor,
        super(ClockComponent.analogTime);

  double _secondHandAngle, _minuteHandAngle, _hourHandAngle;

  set secondHandAngle(double value) {
    assert(value != null);

    if (_secondHandAngle == value) {
      return;
    }

    _secondHandAngle = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  set minuteHandAngle(double value) {
    assert(value != null);

    if (_minuteHandAngle == value) {
      return;
    }

    _minuteHandAngle = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  set hourHandAngle(double value) {
    assert(value != null);

    if (_hourHandAngle == value) {
      return;
    }

    _hourHandAngle = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  int _ballEvery;

  set ballEvery(int value) {
    assert(value != null);

    if (_ballEvery == value) {
      return;
    }

    _ballEvery = value;
    markNeedsPaint();
  }

  bool _use24HourFormat;

  set use24HourFormat(bool value) {
    assert(value != null);

    if (_use24HourFormat == value) {
      return;
    }

    _use24HourFormat = value;
    markNeedsPaint();
  }

  Color _textColor,
      _backgroundColor,
      _backgroundHighlightColor,
      _hourHandColor,
      _minuteHandColor,
      _secondHandColor,
      _shadowColor,
      _borderColor,
      _petalsColor,
      _petalsHighlightColor;

  set textColor(Color value) {
    assert(value != null);

    if (_textColor == value) {
      return;
    }

    _textColor = value;
    markNeedsPaint();
  }

  set backgroundColor(Color value) {
    assert(value != null);

    if (_backgroundColor == value) {
      return;
    }

    _backgroundColor = value;
    markNeedsPaint();
  }

  set backgroundHighlightColor(Color value) {
    assert(value != null);

    if (_backgroundHighlightColor == value) {
      return;
    }

    _backgroundHighlightColor = value;
    markNeedsPaint();
  }

  set hourHandColor(Color value) {
    assert(value != null);

    if (_hourHandColor == value) {
      return;
    }

    _hourHandColor = value;
    markNeedsPaint();
  }

  set minuteHandColor(Color value) {
    assert(value != null);

    if (_minuteHandColor == value) {
      return;
    }

    _minuteHandColor = value;
    markNeedsPaint();
  }

  set secondHandColor(Color value) {
    assert(value != null);

    if (_secondHandColor == value) {
      return;
    }

    _secondHandColor = value;
    markNeedsPaint();
  }

  set shadowColor(Color value) {
    assert(value != null);

    if (_shadowColor == value) {
      return;
    }

    _shadowColor = value;
    markNeedsPaint();
  }

  set borderColor(Color value) {
    assert(value != null);

    if (_borderColor == value) {
      return;
    }

    _borderColor = value;
    markNeedsPaint();
  }

  set petalsColor(Color value) {
    assert(value != null);

    if (_petalsColor == value) {
      return;
    }

    _petalsColor = value;
    markNeedsPaint();
  }

  set petalsHighlightColor(Color value) {
    assert(value != null);

    if (_petalsHighlightColor == value) {
      return;
    }

    _petalsHighlightColor = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData.hasSemanticsInformation = true;

    bounceAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    bounceAnimation.removeListener(markNeedsPaint);

    super.detach();
  }

  @override
  bool get sizedByParent => true;

  double _radius;

  @override
  void performResize() {
    size = constraints.biggest;

    // The height is bigger than the radius to account for the bounce.
    _radius = size.width / 2;
  }

  int get second => (_secondHandAngle / pi / 2 * 60).round();

  int get minute => (_minuteHandAngle / pi / 2 * 60).round();

  int get hour => (_hourHandAngle / pi / 2 * 12).round();

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config
      ..label =
          'Analog clock showing hour $hour${_use24HourFormat ? ' (and ${hour + 12})' : ''}, minute $minute, and second $second'
      ..isReadOnly = true
      ..textDirection = TextDirection.ltr;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(
        offset.dx + _radius,
        offset.dy +
            _radius +
            compositionData.bounce.dy * bounceAnimation.value);

    _drawBackground(canvas);

    final balls = 60 ~/ _ballEvery;
    for (var i = 0; i < balls; i++) {
      final angle = pi * 2 / 60 * _ballEvery * i,
          center = Offset.fromDirection(
        // Need to subtract a quarter of the circle because
        // Offset.fromDirection starts at positive x.
        angle - pi / 2,
        _radius / 2.56,
      ),
          circle = Rect.fromCircle(center: center, radius: _radius / 15),
          paint = Paint()
            // Using the text color because the purpose of this icon is the same
            // as what text or tick marks do in here: indicate something.
            ..color = Color.lerp(
              _textColor,
              _backgroundColor,
              // If the ball is currently hitting the clock, i.e. the second hand
              // matches up with the ball icon, then the ball icon should light up.
              // Need to round because of the hand bounce.
              i * _ballEvery % 60 == second ? 1 / 2 : 1 / 19,
            );

      canvas.drawOval(circle, paint);
    }

    final radius24 = _radius * .711;

    if (_use24HourFormat) {
      // Draw smaller ring.
      canvas.drawOval(
          Rect.fromCircle(center: Offset.zero, radius: radius24),
          Paint()
            ..color = _borderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = _radius / 348);
    }

    final largeDivisions = 12, smallDivisions = 60;

    // Ticks indicating minutes and seconds (both 60).
    for (var n = smallDivisions; n > 0; n--) {
      // Do not draw small ticks when large ones will be drawn afterwards anyway.
      if (n % (smallDivisions / largeDivisions) != 0) {
        final height = _radius / 27;
        canvas.drawRect(
            Rect.fromCenter(
              center: Offset(0, (-size.width + height) / 2),
              width: _radius / 195,
              height: height,
            ),
            Paint()..color = _textColor);
      }

      // Draw 24 hour minute tick marks further inwards.
      if (_use24HourFormat) {
        final w = _radius / 197, h = _radius / 45;
        canvas.drawRect(
            Rect.fromLTWH(
              -w / 2,
              -radius24,
              w,
              -h,
            ),
            Paint()..color = _textColor);
      }

      // This will go back to 0 at the end of loop,
      // i.e. at `-pi * 2` which is rendered as the same.
      canvas.rotate(-pi * 2 / smallDivisions);
    }

    // Ticks and numbers indicating hours.
    for (var n = largeDivisions; n > 0; n--) {
      final height = _radius / 61;
      canvas.drawRect(
          Rect.fromCenter(
            center: Offset(0, (-size.width + height) / 2),
            width: _radius / 68,
            height: height,
          ),
          Paint()..color = _textColor);

      final painter = TextPainter(
        text: TextSpan(
          text: '$n',
          style: TextStyle(
            color: _textColor,
            fontSize: _radius / 7.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(
          -painter.width / 2,
          -_radius +
              // Push the numbers inwards a bit.
              _radius / 18,
        ),
      );

      if (_use24HourFormat) {
        // Draw hours 13-24 and marks further inwards.
        () {
          final w = _radius / 124, h = _radius / 35;
          canvas.drawRect(
              Rect.fromLTWH(
                -w / 2,
                -radius24,
                w,
                -h,
              ),
              Paint()..color = _textColor);

          final painter = TextPainter(
            text: TextSpan(
              text: '${n + 12}',
              style: TextStyle(
                color: _textColor,
                fontSize: _radius / 9,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          painter.layout();
          painter.paint(
            canvas,
            Offset(
              -painter.width / 2,
              -radius24 + _radius / 29,
            ),
          );
        }();
      }

      // Like above, this will go back to 0 at the end of loop,
      // i.e. at `-pi * 2` which is rendered as the same.
      canvas.rotate(-pi * 2 / largeDivisions);
    }

    canvas.drawPetals(_petalsColor, _petalsHighlightColor, _radius);

    // This is the order of the shadow elevations as well, i.e.
    // hour hand is located highest and the minute hand lowest.
    _drawMinuteHand(canvas);
    _drawSecondHand(canvas);
    _drawHourHand(canvas);

    canvas.drawLid(
      _backgroundColor,
      _backgroundHighlightColor,
      _shadowColor,
      _radius / 27,
      _radius / 49,
    );

    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final fullCircleRect =
            Rect.fromCircle(center: Offset.zero, radius: _radius),
        shader = ui.Gradient.radial(
      fullCircleRect.center,
      _radius,
      [_backgroundHighlightColor, _backgroundColor],
      const [0, .7],
    );

    canvas.drawOval(
        fullCircleRect,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = shader);

    // Border
    canvas.drawOval(
        fullCircleRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = _borderColor
          // See thermometer border (`temperature.dart`)
          // for an explanation as to why this is.
          ..strokeWidth = _radius / 612);
  }

  void _drawHourHand(Canvas canvas) {
    canvas.save();

    canvas.rotate(_hourHandAngle);

    final paint = Paint()
          ..color = _hourHandColor
          ..style = PaintingStyle.fill,
        w = _radius / 42,
        h = -_radius / 2.49,
        bw = _radius / 6.3,
        bh = _radius / 7,
        path = Path()
          ..moveTo(0, 0)
          ..lineTo(-w / 2, 0)
          ..lineTo(-w / 2, h)
          ..leafTipTo(-w / 2, h, 0, h - bh, bw / 2, 4)
          ..lineTo(w / 2, 0)
          ..close();

    // I have open questions about Canvas.drawShadow (see
    // https://github.com/flutter/flutter/issues/48027 and
    // https://stackoverflow.com/q/59549244/6509751).
    // I also just noticed that I opened that issue exactly on
    // New Year's first minute - was not on purpose, but this
    // should show something about my relationship to this project :)
    canvas.drawShadow(path, _shadowColor, _radius / 57, false);
    // The shadow needs to be drawn first because it appears
    // below the actual hand.
    canvas.drawPath(path, paint);

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

    canvas.drawShadow(path, _shadowColor, _radius / 89, false);
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  void _drawSecondHand(Canvas canvas) {
    canvas.save();
    // Second hand design parts: rotate in order to easily draw the parts facing straight up.
    canvas.transform(Matrix4.rotationZ(_secondHandAngle).storage);

    final paint = Paint()
          ..color = _secondHandColor
          ..style = PaintingStyle.fill,
        // These are height and width.
        h = -_radius / 1.08,
        w = _radius / 84.51,
        // These are total width of the design part &
        // the height where it starts and ends.
        dw = _radius / 35.52,
        sh = -_radius / 2.85,
        // This matches the 24 hour ring.
        eh = -_radius * .711,
        // These are Opposite End start, height,
        // indent, and width.
        oes = _radius / 9,
        oeh = _radius / 8,
        oei = _radius / 8.37,
        oew = _radius / 16,
        path = Path()
          ..moveTo(0, 0)
          ..lineTo(-w / 2, 0)
          ..lineTo(-w / 2, sh)
          ..lineTo(w / 2, sh)
          ..lineTo(w / 2, 0)
          ..close()
          // Left side of the design part in the middle
          ..moveTo(-w / 2, sh)
          ..lineTo(-dw / 2, sh)
          ..lineTo(-dw / 2, eh)
          ..lineTo(-w / 2, eh)
          ..close()
          // Other side of the part
          ..moveTo(w / 2, sh)
          ..lineTo(dw / 2, sh)
          ..lineTo(dw / 2, eh)
          ..lineTo(w / 2, eh)
          ..close()
          // End of hand
          ..moveTo(-w / 2, eh)
          ..lineTo(-w / 2, h)
          ..lineTo(w / 2, h)
          ..lineTo(w / 2, eh)
          ..close()
          // Opposite end
          ..moveTo(-w / 2, 0)
          ..lineTo(-w / 2, oes)
          ..lineTo(-oew / 2, oes + oeh)
          ..lineTo(0, oes + oei)
          ..lineTo(oew / 2, oes + oeh)
          ..lineTo(w / 2, oes)
          ..lineTo(w / 2, 0)
          ..close();

    canvas.drawShadow(path, _shadowColor, _radius / 64, false);
    canvas.drawPath(path, paint);

    canvas.restore();
  }
}
