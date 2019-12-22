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
  Tween<double> _angle;

  double get _angleFromModel =>
      2 *
      pi /
      WeatherCondition.values.length *
      -WeatherCondition.values.indexOf(widget.model.weatherCondition);

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _angle = visitor(
        _angle, _angleFromModel, (value) => Tween<double>(begin: value));
  }

  @override
  Widget build(BuildContext context) {
    return Weather(
      conditions: WeatherCondition.values.map(describeEnum).toList(),
      angle: _angle?.evaluate(animation) ?? 0,
      textStyle: Theme.of(context).textTheme.body1,
    );
  }
}

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

class WeatherChildrenParentData
    extends CompositionChildrenParentData<WeatherCondition> {}

class RenderWeather extends RenderCompositionChild {
  RenderWeather({
    this.conditions,
    this.angle,
    this.textStyle,
  }) : super(ClockComponent.weather);

//  @override todo
//  void setupParentData(RenderObject child) {
//    if (child.parentData is! WeatherChildrenParentData) {
//      child.parentData = WeatherChildrenParentData()..valid = false;
//    }
//  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;

    _radius = size.width / 2;
  }

  List<String> conditions;
  double angle;
  TextStyle textStyle;

  double _radius;

  static const arrowColor = Color(0xffffddbb);

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    // Save the initial rotation in order to always draw the arrow pointing straight up.
    canvas.save();
    // Rotate the disc by the given angle.
    canvas.rotate(angle);

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
                  32.79));

      canvas.rotate(2 * pi / divisions);
    }

    // Restore initial rotation.
    canvas.restore();

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

class WeatherIcon extends LeafRenderObjectWidget {
  WeatherIcon({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWeatherIcon();
  }
}

class RenderWeatherIcon extends RenderBox {}
