import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';

class AnimatedWeather extends ImplicitlyAnimatedWidget {
  final ClockModel model;

  const AnimatedWeather({
    Key key,
    Curve curve = const ElasticInOutCurve(.6),
    Duration duration = const Duration(milliseconds: 942),
    this.model,
  }) : super(key: key, curve: curve, duration: duration);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _AnimatedWeatherState();
  }
}

class _AnimatedWeatherState extends AnimatedWidgetBaseState<AnimatedWeather> {
  AngleTween _angle;

  double get _angleValue => _angle?.evaluate(animation) ?? 0;

  /// This finds the angle closest to the current angle based on the fact that an angle of `n * pi * 2 + x` produces the same result as the angle `x`.
  double get _angleFromModel {
    final newAngle = 2 * pi / WeatherCondition.values.length * WeatherCondition.values.indexOf(widget.model.weatherCondition), oldAngle = _angleValue;

    if (newAngle.difference(oldAngle) > (newAngle - pi * 2).difference(oldAngle)) return newAngle - pi * 2;
    if (newAngle.difference(oldAngle) > (newAngle + pi * 2).difference(oldAngle)) return newAngle + pi * 2;

    return newAngle;
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _angle = visitor(_angle, _angleFromModel, (value) => AngleTween(begin: value)) as AngleTween;
  }

  @override
  Widget build(BuildContext context) {
    return Weather(
      angle: _angleValue,
      textStyle: Theme.of(context).textTheme.body1,
      children: WeatherCondition.values.map((condition) => WeatherIcon(condition: condition)).toList(),
    );
  }
}

class Weather extends MultiChildRenderObjectWidget {
  final double angle;
  final TextStyle textStyle;

  Weather({
    Key key,
    @required List<Widget> children,
    @required this.angle,
    @required this.textStyle,
  })  : assert(angle != null),
        assert(textStyle != null),
        super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWeather(angle: angle, textStyle: textStyle);
  }

  @override
  void updateRenderObject(BuildContext context, RenderWeather renderObject) {
    renderObject
      ..angle = angle
      ..textStyle = textStyle
      ..markNeedsPaint();
  }
}

class WeatherChildrenParentData extends CompositionChildrenParentData<WeatherCondition> {
  /// [radius] is simply passed for convenience and [angle] & [indentationFactor] together define where the center of the child should be located.
  double radius, angle, indentationFactor;
}

class RenderWeather extends RenderComposition<WeatherCondition, WeatherChildrenParentData, Weather> {
  RenderWeather({
    this.angle,
    this.textStyle,
  }) : super(WeatherCondition.values);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! WeatherChildrenParentData) {
      child.parentData = WeatherChildrenParentData()..valid = false;
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    final clockCompositionData = parentData as ClockChildrenParentData;

    clockCompositionData
      ..childType = ClockComponent.weather
      ..valid = true;
  }

  double angle;
  TextStyle textStyle;

  double _radius;

  List<WeatherCondition> get conditions => children;

  @override
  void performLayout() {
    super.performLayout();

    size = constraints.biggest;

    _radius = size.width / 2;

    for (final condition in conditions) {
      final child = layoutChildren[condition], childParentData = layoutParentData[condition];

      // Give the icons the full area and make them position themselves correctly and not paint over other children in their paint method (the necessary values are passed in paint).
      child.layout(BoxConstraints.tight(size), parentUsesSize: false);
      childParentData.offset = Offset.zero;
    }
  }

  static const arrowColor = Color(0xffffddbb), backgroundColor = Color(0xff2c6aee), indentationFactor = .48;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    // Save the initial rotation in order to always draw the arrow pointing straight up.
    canvas.save();
    // Rotate the disc by the given angle. This defines how a potential background that can be drawn inside here will look.
    canvas.rotate(angle);

    // Background
    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: _radius), Paint()..color = backgroundColor);

    // Restore initial rotation.
    canvas.restore();

    // Revert translation before drawing the children.
    canvas.restore();

    // Need the rotation angle of the whole weather widget and the angle by which each condition is offset.
    var conditionAngle = 0.0;
    for (final condition in conditions) {
      final childParentData = layoutParentData[condition];

      childParentData
        ..indentationFactor = indentationFactor
        ..radius = _radius
        ..angle = angle + conditionAngle;

      paintChild(condition);

      conditionAngle -= pi * 2 / conditions.length;
    }

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    // Draw tip of the arrow pointing up.
    final h = _radius * (indentationFactor - 1), s = _radius / 16;
    canvas.drawPath(
        Path()
          // Remember that this is the center of the circle.
          ..moveTo(0, h + s)
          ..lineTo(-s, h + s)
          ..lineTo(0, h)
          ..lineTo(s, h + s)
          ..lineTo(0, h + s)
          ..close(),
        Paint()
          ..color = arrowColor
          ..style = PaintingStyle.fill);
    // Draw the rest of the arrow.
    canvas.drawLine(
        Offset.zero,
        Offset(0, h + s),
        Paint()
          ..color = arrowColor
          ..strokeWidth = _radius / 42
          ..strokeCap = StrokeCap.round);

    canvas.restore();
  }
}

class WeatherIcon extends LeafRenderObjectWidget {
  final WeatherCondition condition;

  WeatherIcon({
    Key key,
    @required this.condition,
  })  : assert(condition != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWeatherIcon(
      condition: condition,
    );
  }
}

/// Doodle-like icons based on geometric shapes and paths that represent the different weather conditions.
///
/// I drew these "by hand", as in I had some actual image or one in my head that I tried to replicate
/// using geometric shapes, lines, and curves. It involved trial and error sometimes, but I think that
/// the icons turned out recognizable right away, which surprised me to some degree.
/// However, I do not really like how they look, i.e. they are all at least a bit off, sometimes more
/// than that, which is why I plan on coming back to this later and making them look decent - it
/// might also involve animating them.
/// It is possible that I forget to remove this section or that I leave it intentionally - in order
/// to make it easier to find.
class RenderWeatherIcon extends RenderCompositionChild<WeatherCondition, WeatherChildrenParentData> {
  RenderWeatherIcon({
    WeatherCondition condition,
  }) : super(condition);

  WeatherCondition get condition => childType;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  double get radius => compositionData.radius;

  double get indentationFactor => compositionData.indentationFactor;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    // Clip the area of the parent (weather circle).
    context.canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius)));

    canvas.rotate(compositionData.angle);

    // Position and rotate the canvas according to the values stored in the composition data.
    final iconPosition = Offset(0, radius * (indentationFactor - 1));

    context.pushTransform(needsCompositing, offset, Matrix4.translationValues(iconPosition.dx, iconPosition.dy, 0), paintIcon);

    canvas.restore();
  }

  void paintIcon(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();

    // Having the center in the middle between the tip of the arrow and the border of the circle should be good.
    canvas.translate(0, radius * -indentationFactor / 2);

    switch (condition) {
      case WeatherCondition.cloudy:
        paintCloudy(canvas);
        break;
      case WeatherCondition.foggy:
        paintFoggy(canvas);
        break;
      case WeatherCondition.rainy:
        paintRainy(canvas);
        break;
      case WeatherCondition.snowy:
        paintSnowy(canvas);
        break;
      case WeatherCondition.sunny:
        paintSunny(canvas);
        break;
      case WeatherCondition.thunderstorm:
        paintThunderstorm(canvas);
        break;
      case WeatherCondition.windy:
        paintWindy(canvas);
        break;
    }

    canvas.restore();
  }

  static const cloudColor = Color(0xcbc1beba);

  void _paintCloud(Canvas canvas, double tx, double ty, double s) {
    canvas.save();

    canvas.translate(tx, ty);
    canvas.scale(s);

    final h = radius * indentationFactor / 4, w = h * 2.7;

    canvas.drawPath(
        Path()
          ..moveTo(0, h / 2)
          ..lineTo(-w / 2, h / 2)
          ..quadraticBezierTo(
            -w / 2 - h / 4,
            h / 3,
            -w / 2.2,
            h / 12,
          )
          ..quadraticBezierTo(
            w / -2.9,
            h / -2.3,
            w / -7,
            h / -5,
          )
          ..quadraticBezierTo(
            w / 5,
            h / -1.1,
            w / 2.2,
            h / 9,
          )
          ..quadraticBezierTo(
            w / 2 + h / 4,
            h / 3,
            w / 2,
            h / 2,
          )
          ..close(),
        Paint()
          ..color = cloudColor
          ..style = PaintingStyle.fill);

    canvas.restore();
  }

  void paintCloudy(Canvas canvas) {
    // I could also achieve this by passing different values to _paintCloud,
    // but I only realized that I wanted a different position later and it is easier to
    // adjust it like this.
    canvas.translate(0, radius * indentationFactor / 6);
    canvas.scale(1.1);

    _paintCloud(canvas, -radius * indentationFactor / 4, -radius * indentationFactor / 18, .8);
    _paintCloud(canvas, radius * indentationFactor / 4, -radius * indentationFactor / 8, .8);
    _paintCloud(canvas, 0, 0, 1.3);
    _paintCloud(canvas, -radius * indentationFactor / 4.2, -radius * indentationFactor / 3.7, .6);
  }

  static const fogColor = Color(0xc5cdc8be);

  void paintFoggy(Canvas canvas) {
    final g = radius * indentationFactor / 14;

    // Once again, it is easier to adjust it like this afterwards.
    canvas.translate(g * .71, g * .62);
    canvas.scale(.96);

    final paint = Paint()
      ..color = fogColor
      ..strokeWidth = g
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(Offset(-g * 5, -3 * g), Offset(-g, -3 * g), paint)
      ..drawLine(Offset(-g * 3, -g), Offset(g * 4, -g), paint)
      ..drawLine(Offset(g * -6, g), Offset(g * 2, g), paint)
      ..drawLine(Offset(g * -5, g * 3), Offset(g * 4, g * 3), paint);
  }

  static const raindropColor = Color(0xdda1c6cc), raindrops = 42;

  void _paintRain(Canvas canvas, int r, int n, double s) {
    canvas.save();
    canvas.scale(s);

    final random = Random(r),
        raindropPaint = Paint()
          ..color = raindropColor
          ..strokeWidth = radius / 142;

    for (var i = 0; i < n; i++) {
      final horizontalShift = random.nextDouble() - 1 / 2, verticalShift = random.nextDouble() - 1 / 2, heightShift = random.nextDouble(), start = Offset(horizontalShift * radius / 4, verticalShift * radius / 7);

      canvas.drawLine(start, start + Offset(0, radius / 17 * (1 / 2 + heightShift)), raindropPaint);
    }

    canvas.restore();
  }

  void paintRainy(Canvas canvas) {
    _paintRain(canvas, 0, raindrops, 1.42);
  }

  static const snowColor = Color(0xbbfffafa), snowflakes = 61, snow = 23;

  void paintSnowy(Canvas canvas) {
    final random = Random(815174);

    // Draw snowflakes
    final paint = Paint()..color = snowColor;
    for (var i = 0; i < snowflakes; i++) {
      final verticalShift = random.nextDouble() - 1 / 2, horizontalShift = random.nextDouble() - 1 / 2, diameterShift = random.nextDouble(), diameter = radius / 49 * (1 + diameterShift / 2);

      canvas.drawOval(Rect.fromCircle(center: Offset(radius / 3 * horizontalShift, radius / 5 * verticalShift), radius: diameter / 2), paint);
    }

    // Draw some laying on the ground
    for (var i = 0; i < snow; i++) {
      final verticalShift = random.nextDouble(), horizontalShift = random.nextDouble() - 1 / 2, diameterShift = random.nextDouble(), diameter = radius / 33 * (1 + diameterShift / 2);

      canvas.drawOval(Rect.fromCircle(center: Offset(radius / 3.5 * horizontalShift, radius / 9 + radius / 42 * verticalShift), radius: diameter / 2), paint);
    }
  }

  static const sunColor = Color(0xfffcd440), sunRays = 12;

  void paintSunny(Canvas canvas) {
    final paint = Paint()
      ..color = sunColor
      ..strokeWidth = radius / 124;

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: radius / 9), paint);

    for (var i = 0; i < sunRays; i++) {
      final direction = pi * 2 / sunRays * i;
      canvas.drawLine(Offset.fromDirection(direction, radius / 8), Offset.fromDirection(direction, radius / 6), paint);
    }
  }

  static const lightningColor = Color(0xfffdd023), thunderstormRaindrops = 11;

  void paintThunderstorm(Canvas canvas) {
    // Draw lightning
    final lightningPath = Path()
      ..moveTo(radius * -indentationFactor / 4, radius * -indentationFactor / 4)
      ..relativeLineTo(radius / 14, 0)
      ..relativeLineTo(radius / 15, radius / 7)
      ..relativeLineTo(radius / 14, 0)
      ..relativeLineTo(radius / 17, radius / 8)
      ..relativeLineTo(-radius / 9, -radius / 13)
      ..relativeLineTo(-radius / 14, 0)
      ..close();
    canvas.drawPath(
        lightningPath,
        Paint()
          ..color = lightningColor
          ..style = PaintingStyle.fill);

    // Draw raindrops
    _paintRain(canvas, 435, thunderstormRaindrops, 1);
  }

  static const primaryWindColor = Color(0xff96c4e8), secondaryWindColor = Color(0xff008abf);

  void _paintWind(Canvas canvas, Color c, double tx, double ty, double s, double l1, double l2, double l3) {
    canvas.save();
    canvas.translate(tx, ty);
    canvas.scale(s);

    final mf = radius * indentationFactor / 5, hd = mf / 4;

    // Draw wind symbol consisting of four paths
    final paint = Paint()
          ..color = c
          ..strokeWidth = radius / 114
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
        paths = [
      Path()
        ..moveTo(mf * (1 - l1), -hd)
        ..lineTo(2 * mf, -hd)
        ..quadraticBezierTo(
          2.6 * mf,
          -hd,
          2.6 * mf,
          -hd * 3,
        )
        ..cubicTo(
          2.5 * mf,
          -hd * 6,
          1.4 * mf,
          -hd * 4.2,
          1.8 * mf,
          -hd * 2.3,
        ),
      Path()
        ..moveTo(2.542 * mf, -hd)
        ..lineTo(3 * mf, -hd)
        ..quadraticBezierTo(
          3.34 * mf,
          -hd,
          3.3 * mf,
          -hd * 2.3,
        )
        ..cubicTo(
          3.17 * mf,
          -hd * 3.48,
          2.77 * mf,
          -hd * 2.7,
          2.96 * mf,
          -hd * 1.83,
        ),
      Path()
        ..moveTo(mf * (1 - l2), 0)
        ..lineTo(3 * mf, 0)
        ..quadraticBezierTo(
          3.48 * mf,
          0,
          3.46 * mf,
          hd * 1.49,
        )
        ..cubicTo(
          3.4 * mf,
          hd * 3.6,
          2.56 * mf,
          hd * 2.4,
          3 * mf,
          hd * 1.1,
        ),
      Path()
        ..moveTo(mf * (1 - l3), hd)
        ..lineTo(2 * mf, hd)
        ..quadraticBezierTo(
          2.43 * mf,
          hd,
          2.43 * mf,
          hd * 2.8,
        )
        ..cubicTo(
          2.4 * mf,
          hd * 4.8,
          1.6 * mf,
          hd * 3.99,
          1.9 * mf,
          hd * 2.36,
        ),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  void paintWindy(Canvas canvas) {
    // Primary wind symbol
    _paintWind(canvas, primaryWindColor, 0, radius * indentationFactor / 17, .96, 2, 1.8, 1);

    // Upper wind symbol
    _paintWind(canvas, secondaryWindColor, radius * indentationFactor / -3, radius * indentationFactor / -5, .8, 2, 1.8, 1);

    // Lower wind symbol
    _paintWind(canvas, secondaryWindColor, radius * indentationFactor / -6, radius * indentationFactor / 3, .7, 1, 1, 1);
  }

  /// Paints icon in neutral orientation in big in order to easily design it.
  @override
  void debugPaint(PaintingContext context, Offset offset) {
    assert(() {
      // Leaving this as an option for now as I want to be able to come back later to improve the icons.
      return true;

      final canvas = context.canvas;

      canvas.drawPaint(Paint()..color = const Color(0x22000000));

      canvas.save();
      canvas.translate(534, 350);
      canvas.scale(2);
      paintFoggy(canvas);

      canvas.restore();
      return true;
    }());
    super.debugPaint(context, offset);
  }
}
