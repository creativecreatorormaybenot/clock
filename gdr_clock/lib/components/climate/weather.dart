import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';

class AnimatedWeather extends ImplicitlyAnimatedWidget {
  final ClockModel model;

  final Map<ClockColor, Color> palette;

  const AnimatedWeather({
    Key key,
    Curve curve = const ElasticInOutCurve(.6),
    Duration duration = const Duration(seconds: 1),
    @required this.model,
    @required this.palette,
  })  : assert(model != null),
        assert(palette != null),
        super(key: key, curve: curve, duration: duration);

  @override
  _AnimatedWeatherState createState() {
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
      arrowColor: widget.palette[ClockColor.weatherArrow],
      backgroundColor: widget.palette[ClockColor.weatherBackground],
      backgroundHighlightColor: widget.palette[ClockColor.weatherBackgroundHighlight],
      borderColor: widget.palette[ClockColor.border],
      shadowColor: widget.palette[ClockColor.shadow],
      children: WeatherCondition.values.map(weatherIcon).toList(),
    );
  }

  Widget weatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.cloudy:
        return Cloudy(
          cloudColor: widget.palette[ClockColor.cloud],
        );
      case WeatherCondition.foggy:
        return Foggy(
          fogColor: widget.palette[ClockColor.fog],
        );
      case WeatherCondition.rainy:
        return Rainy(
          raindropColor: widget.palette[ClockColor.raindrop],
        );
      case WeatherCondition.snowy:
        return Snowy(
          snowflakeColor: widget.palette[ClockColor.snowflake],
        );
      case WeatherCondition.sunny:
        return Sunny(
          sunColor: widget.palette[ClockColor.sun],
        );
      case WeatherCondition.thunderstorm:
        return Thunderstorm(
          lightningColor: widget.palette[ClockColor.lightning],
          raindropColor: widget.palette[ClockColor.raindrop],
        );
      case WeatherCondition.windy:
        return Windy(
          primaryColor: widget.palette[ClockColor.windPrimary],
          secondaryColor: widget.palette[ClockColor.windSecondary],
        );
    }
    throw UnimplementedError('Missing weather icon for $condition.');
  }
}

class Weather extends MultiChildRenderObjectWidget {
  final double angle;

  final Color arrowColor, backgroundColor, backgroundHighlightColor, borderColor, shadowColor;

  Weather({
    Key key,
    @required List<Widget> children,
    @required this.angle,
    @required this.arrowColor,
    @required this.backgroundColor,
    @required this.backgroundHighlightColor,
    @required this.borderColor,
    @required this.shadowColor,
  })  : assert(angle != null),
        assert(arrowColor != null),
        assert(backgroundColor != null),
        assert(backgroundHighlightColor != null),
        assert(borderColor != null),
        assert(shadowColor != null),
        super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWeather(
      angle: angle,
      arrowColor: arrowColor,
      backgroundColor: backgroundColor,
      backgroundHighlightColor: backgroundHighlightColor,
      borderColor: borderColor,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderWeather renderObject) {
    renderObject
      ..angle = angle
      ..arrowColor = arrowColor
      ..backgroundColor = backgroundColor
      ..backgroundHighlightColor = backgroundHighlightColor
      ..borderColor = borderColor
      ..shadowColor = shadowColor;
  }
}

class WeatherChildrenParentData extends CompositionChildrenParentData<WeatherCondition> {
  /// [radius] is simply passed for convenience and [angle] & [indentationFactor] together define where the center of the child should be located.
  double radius, angle, indentationFactor;
}

class RenderWeather extends RenderComposition<WeatherCondition, WeatherChildrenParentData, Weather> {
  RenderWeather({
    double angle,
    Color arrowColor,
    Color backgroundColor,
    Color backgroundHighlightColor,
    Color borderColor,
    Color shadowColor,
  })  : _angle = angle,
        _arrowColor = arrowColor,
        _backgroundColor = backgroundColor,
        _backgroundHighlightColor = backgroundHighlightColor,
        _borderColor = borderColor,
        _shadowColor = shadowColor,
        super(WeatherCondition.values);

  double _angle;

  set angle(double value) {
    assert(value != null);

    if (_angle == value) {
      return;
    }

    _angle = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  Color _arrowColor, _backgroundColor, _backgroundHighlightColor, _borderColor, _shadowColor;

  set arrowColor(Color value) {
    assert(value != null);

    if (_arrowColor == value) {
      return;
    }

    _arrowColor = value;
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

  set borderColor(Color value) {
    assert(value != null);

    if (_borderColor == value) {
      return;
    }

    _borderColor = value;
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
      ..valid = true
      ..hasSemanticsInformation = true;
  }

  double _radius;

  List<WeatherCondition> get conditions => children;

  WeatherCondition get condition => conditions[(_angle / pi / 2 * conditions.length).round()];

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config
      ..isReadOnly = true
      ..textDirection = TextDirection.ltr
      ..label = 'Weather condition is ${describeEnum(condition)}';
  }

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

  static const indentationFactor = .48;

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
    canvas.rotate(_angle);

    _drawBackground(canvas);

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
        ..angle = _angle + conditionAngle;

      paintChild(condition);

      conditionAngle -= pi * 2 / conditions.length;
    }

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    canvas.drawPetals(_radius);

    _drawArrow(canvas);

    canvas.restore();
  }

  void _drawArrow(Canvas canvas) {
    final h = _radius * (indentationFactor - 1),
        s = _radius / 16,
        w = _radius / 42,
        path = Path()
          // Remember that this is the center of the circle.
          ..moveTo(0, h + s)
          ..lineTo(-s, h + s)
          ..lineTo(0, h)
          ..lineTo(s, h + s)
          ..lineTo(0, h + s)
          ..close()
          ..moveTo(-w / 2, 0)
          ..lineTo(-w / 2, h + s)
          ..lineTo(w / 2, h + s)
          ..lineTo(w / 2, 0)
          // Round cap
          ..halfCircleTo(
            -w / 2,
            0,
            w / 2,
          )
          ..close(),
        paint = Paint()
          ..color = _arrowColor
          ..style = PaintingStyle.fill;

    canvas.drawShadow(path, _shadowColor, _radius / 54, false);
    canvas.drawPath(path, paint);
  }

  void _drawBackground(Canvas canvas) {
    final fullCircleRect = Rect.fromCircle(center: Offset.zero, radius: _radius),
        shader = ui.Gradient.radial(
      fullCircleRect.center,
      _radius,
      [
        Color.lerp(_backgroundHighlightColor, _backgroundColor, 3 / 5),
        _backgroundColor,
      ],
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
          ..strokeWidth = _radius / 217);
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
abstract class RenderWeatherIcon extends RenderCompositionChild<WeatherCondition, WeatherChildrenParentData> {
  final bool debugPaintConditionEnabled;

  RenderWeatherIcon(WeatherCondition condition, [this.debugPaintConditionEnabled = false]) : super(condition);

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

  /// Paints (`paintX` because of [PaintingContext]) the appropriate icon.
  /// Information on the naming scheme I chose can be found at [ExtendedCanvas.drawPetals].
  void paintIcon(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();

    // Having the center in the middle between the tip of the arrow and the border of the circle should be good.
    canvas.translate(0, radius * -indentationFactor / 2);

    drawCondition(canvas);

    canvas.restore();
  }

  void drawCondition(Canvas canvas);

  /// Paints icon in neutral orientation in big in order to easily design it.
  @override
  void debugPaint(PaintingContext context, Offset offset) {
    assert(() {
      // Leaving this as an option for now as I want to be able to come back later to improve the icons.
      if (!debugPaintConditionEnabled) return true;

      final canvas = context.canvas;

      canvas.drawPaint(Paint()..color = const Color(0x22000000));

      canvas.save();
      canvas.translate(534, 350);
      canvas.scale(2);
      drawCondition(canvas);

      canvas.restore();
      return true;
    }());
    super.debugPaint(context, offset);
  }
}

class Cloudy extends LeafRenderObjectWidget {
  final Color cloudColor;

  Cloudy({
    Key key,
    @required this.cloudColor,
  })  : assert(cloudColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCloudy(
      cloudColor: cloudColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCloudy renderObject) {
    renderObject..cloudColor = cloudColor;
  }
}

class RenderCloudy extends RenderWeatherIcon {
  RenderCloudy({
    Color cloudColor,
  })  : _cloudColor = cloudColor,
        super(WeatherCondition.cloudy);

  Color _cloudColor;

  set cloudColor(Color value) {
    assert(value != null);

    if (_cloudColor == value) {
      return;
    }

    _cloudColor = value;
    markNeedsPaint();
  }

  @override
  void drawCondition(Canvas canvas) {
    // I could also achieve this by passing different values to _drawCloud,
    // but I only realized that I wanted a different position later and it is easier to
    // adjust it like this.
    canvas.translate(0, radius * indentationFactor / 6);
    canvas.scale(1.1);

    _drawCloud(canvas, -radius * indentationFactor / 4, -radius * indentationFactor / 18, .8);
    _drawCloud(canvas, radius * indentationFactor / 4, -radius * indentationFactor / 8, .8);
    _drawCloud(canvas, 0, 0, 1.3);
    _drawCloud(canvas, -radius * indentationFactor / 4.2, -radius * indentationFactor / 3.7, .6);
  }

  void _drawCloud(Canvas canvas, double tx, double ty, double s) {
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
          ..color = _cloudColor
          ..style = PaintingStyle.fill);

    canvas.restore();
  }
}

class Foggy extends LeafRenderObjectWidget {
  final Color fogColor;

  Foggy({
    Key key,
    @required this.fogColor,
  })  : assert(fogColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFoggy(
      fogColor: fogColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFoggy renderObject) {
    renderObject..fogColor = fogColor;
  }
}

class RenderFoggy extends RenderWeatherIcon {
  RenderFoggy({
    Color fogColor,
  })  : _fogColor = fogColor,
        super(WeatherCondition.foggy);

  Color _fogColor;

  set fogColor(Color value) {
    assert(value != null);

    if (_fogColor == value) {
      return;
    }

    _fogColor = value;
    markNeedsPaint();
  }

  @override
  void drawCondition(Canvas canvas) {
    final g = radius * indentationFactor / 14;

    // Once again, it is easier to adjust it like this afterwards.
    canvas.translate(g * .71, g * .62);
    canvas.scale(.96);

    final paint = Paint()
      ..color = _fogColor
      ..strokeWidth = g
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(Offset(-g * 5, -3 * g), Offset(-g, -3 * g), paint)
      ..drawLine(Offset(-g * 3, -g), Offset(g * 4, -g), paint)
      ..drawLine(Offset(g * -6, g), Offset(g * 2, g), paint)
      ..drawLine(Offset(g * -5, g * 3), Offset(g * 4, g * 3), paint);
  }
}

class Rainy extends LeafRenderObjectWidget {
  final int raindrops;

  final Color raindropColor;

  Rainy({
    Key key,
    this.raindrops = 42,
    @required this.raindropColor,
  })  : assert(raindropColor != null),
        super(key: key);

  @override
  RenderRainy createRenderObject(BuildContext context) {
    return RenderRainy(
      raindrops: raindrops,
      raindropColor: raindropColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderRainy renderObject) {
    renderObject
      ..raindrops = raindrops
      ..raindropColor = raindropColor;
  }
}

class RenderRainy extends RenderWeatherIcon {
  RenderRainy({
    int raindrops,
    Color raindropColor,
  })  : _raindrops = raindrops,
        _raindropColor = raindropColor,
        super(WeatherCondition.rainy);

  int _raindrops;

  set raindrops(int value) {
    assert(value != null);

    if (_raindrops == value) {
      return;
    }

    _raindrops = value;
    markNeedsPaint();
  }

  Color _raindropColor;

  set raindropColor(Color value) {
    assert(value != null);

    if (_raindropColor == value) {
      return;
    }

    _raindropColor = value;
    markNeedsPaint();
  }

  @override
  void drawCondition(Canvas canvas) {
    _drawRain(canvas, _raindropColor, radius, 0, _raindrops, 1.42);
  }
}

void _drawRain(Canvas canvas, Color raindropColor, double radius, int randomSeed, int raindrops, double scale) {
  canvas.save();
  canvas.scale(scale);

  final random = Random(randomSeed),
      raindropPaint = Paint()
        ..color = raindropColor
        ..strokeWidth = radius / 142;

  for (var i = 0; i < raindrops; i++) {
    final horizontalShift = random.nextDouble() - 1 / 2, verticalShift = random.nextDouble() - 1 / 2, heightShift = random.nextDouble(), start = Offset(horizontalShift * radius / 4, verticalShift * radius / 7);

    canvas.drawLine(start, start + Offset(0, radius / 17 * (1 / 2 + heightShift)), raindropPaint);
  }

  canvas.restore();
}

class Snowy extends LeafRenderObjectWidget {
  final int snowflakes,

      /// How many snowflakes are lying on the ground.
      snow;

  final Color snowflakeColor;

  Snowy({
    Key key,
    this.snowflakes = 61,
    this.snow = 23,
    @required this.snowflakeColor,
  })  : assert(snowflakeColor != null),
        super(key: key);

  @override
  RenderSnowy createRenderObject(BuildContext context) {
    return RenderSnowy(
      snowflakes: snowflakes,
      snow: snow,
      snowflakeColor: snowflakeColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSnowy renderObject) {
    renderObject
      ..snowflakes = snowflakes
      ..snow = snow
      ..snowflakeColor = snowflakeColor;
  }
}

class RenderSnowy extends RenderWeatherIcon {
  RenderSnowy({
    int snowflakes,
    int snow,
    Color snowflakeColor,
  })  : _snowflakes = snowflakes,
        _snow = snow,
        _snowflakeColor = snowflakeColor,
        super(WeatherCondition.snowy);

  int _snowflakes, _snow;

  set snowflakes(int value) {
    assert(value != null);

    if (_snowflakes == value) {
      return;
    }

    _snowflakes = value;
    markNeedsPaint();
  }

  set snow(int value) {
    assert(value != null);

    if (_snow == value) {
      return;
    }

    _snow = value;
    markNeedsPaint();
  }

  Color _snowflakeColor;

  set snowflakeColor(Color value) {
    assert(value != null);

    if (_snowflakeColor == value) {
      return;
    }

    _snowflakeColor = value;
    markNeedsPaint();
  }

  @override
  void drawCondition(Canvas canvas) {
    final random = Random(815174);

    // Draw snowflakes
    final paint = Paint()..color = _snowflakeColor;
    for (var i = 0; i < _snowflakes; i++) {
      final verticalShift = random.nextDouble() - 1 / 2, horizontalShift = random.nextDouble() - 1 / 2, diameterShift = random.nextDouble(), diameter = radius / 49 * (1 + diameterShift / 2);

      canvas.drawOval(Rect.fromCircle(center: Offset(radius / 3 * horizontalShift, radius / 5 * verticalShift), radius: diameter / 2), paint);
    }

    // Draw some laying on the ground
    for (var i = 0; i < _snow; i++) {
      final verticalShift = random.nextDouble(), horizontalShift = random.nextDouble() - 1 / 2, diameterShift = random.nextDouble(), diameter = radius / 33 * (1 + diameterShift / 2);

      canvas.drawOval(Rect.fromCircle(center: Offset(radius / 3.5 * horizontalShift, radius / 9 + radius / 42 * verticalShift), radius: diameter / 2), paint);
    }
  }
}

class Sunny extends LeafRenderObjectWidget {
  final int sunRays;

  final Color sunColor;

  Sunny({
    Key key,
    this.sunRays = 12,
    @required this.sunColor,
  })  : assert(sunColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSunny(
      sunRays: sunRays,
      sunColor: sunColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSunny renderObject) {
    renderObject
      ..sunRays = sunRays
      ..sunColor = sunColor;
  }
}

class RenderSunny extends RenderWeatherIcon {
  RenderSunny({
    int sunRays,
    Color sunColor,
  })  : _sunRays = sunRays,
        _sunColor = sunColor,
        super(WeatherCondition.sunny);

  int _sunRays;

  set sunRays(int value) {
    assert(value != null);

    if (_sunRays == value) {
      return;
    }

    _sunRays = value;
    markNeedsPaint();
  }

  Color _sunColor;

  set sunColor(Color value) {
    assert(value != null);

    if (_sunColor == value) {
      return;
    }

    _sunColor = value;
    markNeedsPaint();
  }

  @override
  void drawCondition(Canvas canvas) {
    final paint = Paint()
      ..color = _sunColor
      ..strokeWidth = radius / 124;

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: radius / 9), paint);

    for (var i = 0; i < _sunRays; i++) {
      final direction = pi * 2 / _sunRays * i;
      canvas.drawLine(Offset.fromDirection(direction, radius / 8), Offset.fromDirection(direction, radius / 6), paint);
    }
  }
}

class Thunderstorm extends LeafRenderObjectWidget {
  final int raindrops;

  final Color lightningColor, raindropColor;

  Thunderstorm({
    Key key,
    this.raindrops = 11,
    @required this.lightningColor,
    @required this.raindropColor,
  })  : assert(lightningColor != null),
        assert(raindropColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderThunderstorm(
      raindrops: raindrops,
      lightningColor: lightningColor,
      raindropColor: raindropColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderThunderstorm renderObject) {
    renderObject
      ..raindrops = raindrops
      ..lightningColor = lightningColor
      ..raindropColor = raindropColor;
  }
}

class RenderThunderstorm extends RenderWeatherIcon {
  RenderThunderstorm({
    int raindrops,
    Color lightningColor,
    Color raindropColor,
  })  : _raindrops = raindrops,
        _lightningColor = lightningColor,
        _raindropColor = raindropColor,
        super(WeatherCondition.thunderstorm);

  int _raindrops;

  set raindrops(int value) {
    assert(value != null);

    if (_raindrops == value) {
      return;
    }

    _raindrops = value;
    markNeedsPaint();
  }

  Color _lightningColor, _raindropColor;

  set lightningColor(Color value) {
    assert(value != null);

    if (_lightningColor == value) {
      return;
    }

    _lightningColor = value;
    markNeedsPaint();
  }

  set raindropColor(Color value) {
    assert(value != null);

    if (_raindropColor == value) {
      return;
    }

    _raindropColor = value;
    markNeedsPaint();
  }

  @override
  void drawCondition(Canvas canvas) {
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
          ..color = _lightningColor
          ..style = PaintingStyle.fill);

    // Draw raindrops
    _drawRain(canvas, _raindropColor, radius, 435, _raindrops, 1);
  }
}

class Windy extends LeafRenderObjectWidget {
  final Color primaryColor, secondaryColor;

  Windy({
    Key key,
    @required this.primaryColor,
    @required this.secondaryColor,
  })  : assert(primaryColor != null),
        assert(secondaryColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWindy(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderWindy renderObject) {
    renderObject
      ..primaryColor = primaryColor
      ..secondaryColor = secondaryColor;
  }
}

class RenderWindy extends RenderWeatherIcon {
  RenderWindy({
    Color primaryColor,
    Color secondaryColor,
  })  : _primaryColor = primaryColor,
        _secondaryColor = secondaryColor,
        super(WeatherCondition.windy);

  Color _primaryColor, _secondaryColor;

  set primaryColor(Color value) {
    assert(value != null);

    if (_primaryColor == value) {
      return;
    }

    _primaryColor = value;
    markNeedsPaint();
  }

  set secondaryColor(Color value) {
    assert(value != null);

    if (_secondaryColor == value) {
      return;
    }

    _secondaryColor = value;
    markNeedsPaint();
  }

  @override
  void drawCondition(Canvas canvas) {
    // Primary wind symbol
    _drawWind(canvas, _primaryColor, 0, radius * indentationFactor / 17, .96, 2, 1.8, 1);

    // Upper wind symbol
    _drawWind(canvas, _secondaryColor, radius * indentationFactor / -3, radius * indentationFactor / -5, .8, 2, 1.8, 1);

    // Lower wind symbol
    _drawWind(canvas, _secondaryColor, radius * indentationFactor / -6, radius * indentationFactor / 3, .7, 1, 1, 1);
  }

  void _drawWind(Canvas canvas, Color c, double tx, double ty, double s, double l1, double l2, double l3) {
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
}
