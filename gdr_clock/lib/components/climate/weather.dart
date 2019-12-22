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

  double get _angleFromModel => 2 * pi / WeatherCondition.values.length * -WeatherCondition.values.indexOf(widget.model.weatherCondition);

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _angle = visitor(_angle, _angleFromModel, (value) => Tween<double>(begin: value));
  }

  @override
  Widget build(BuildContext context) {
    return Weather(
      angle: _angle?.evaluate(animation) ?? 0,
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

  static const arrowColor = Color(0xffffddbb), indentationFactor = .16;

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
    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: _radius), Paint()..color = const Color(0xff3c9aff));

    // Restore initial rotation.
    canvas.restore();

    // Revert translation before drawing the children.
    canvas.restore();

    // Need the rotation angle of the whole weather widget and the angle by which each condition is offset.
    var conditionAngle = -pi / 2;
    for (final condition in conditions) {
      final childParentData = layoutParentData[condition];

      childParentData
        ..indentationFactor = indentationFactor
        ..radius = _radius
        ..angle = angle + conditionAngle;

      paintChild(condition);

      conditionAngle += pi * 2 / conditions.length;
    }

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

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

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    // Clip the area of the parent (weather circle).
    context.canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: compositionData.radius)));

    canvas.rotate(compositionData.angle);

    // Position and rotate the canvas according to the values stored in the composition data.
    final iconPosition = Offset.fromDirection(0, compositionData.radius * (1 - compositionData.indentationFactor));

    context.pushTransform(needsCompositing, offset, Matrix4.translationValues(iconPosition.dx, iconPosition.dy, 0), paintIcon);

    canvas.restore();
  }

  void paintIcon(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

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
  }

  void paintCloudy(Canvas canvas) {
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 20, height: 30), Paint()..color = const Color(0xffff4ea9));
  }

  void paintFoggy(Canvas canvas) {
    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: 50), Paint());
  }

  void paintRainy(Canvas canvas) {
    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: 50), Paint());
  }

  void paintSnowy(Canvas canvas) {
    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: 50), Paint());
  }

  void paintSunny(Canvas canvas) {
    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: 50), Paint());
  }

  void paintThunderstorm(Canvas canvas) {
    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: 50), Paint());
  }

  void paintWindy(Canvas canvas) {
    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: 50), Paint());
  }
}
