import 'dart:math';
import 'dart:ui' as ui;

import 'package:canvas_clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

const iconLoopDuration = Duration(seconds: 4);

class AnimatedWeather extends ImplicitlyAnimatedWidget {
  final ClockModel model;

  final Map<ClockColor, Color> palette;

  const AnimatedWeather({
    Key key,
    Curve curve = const ElasticInOutCurve(.73),
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

class _AnimatedWeatherState extends AnimatedWidgetBaseState<AnimatedWeather> with TickerProviderStateMixin {
  static List<WeatherCondition> get conditions => WeatherCondition.values;

  AngleTween _angle;

  double get _angleValue => _angle?.evaluate(animation) ?? 0;

  /// This finds the angle closest to the current angle based on the fact that an angle of `n * pi * 2 + x` produces the same result as the angle `x`.
  double get _angleFromModel {
    final newAngle = 2 * pi / conditions.length * conditions.indexOf(widget.model.weatherCondition), oldAngle = _angleValue;

    if (newAngle.difference(oldAngle) > (newAngle - pi * 2).difference(oldAngle)) return newAngle - pi * 2;
    if (newAngle.difference(oldAngle) > (newAngle + pi * 2).difference(oldAngle)) return newAngle + pi * 2;

    return newAngle;
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _angle = visitor(_angle, _angleFromModel, (value) => AngleTween(begin: value)) as AngleTween;
  }

  List<AnimationController> iconLoopControllers;

  @override
  void initState() {
    super.initState();

    iconLoopControllers = List.generate(
        conditions.length,
        (_) => AnimationController(
              vsync: this,
              duration: const Duration(seconds: 3),
            ));
  }

  @override
  void dispose() {
    for (final controller in iconLoopControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  AnimationController currentlyAnimating;

  int get currentIndex {
    final n = conditions.length;
    return (_angleValue / pi / 2 * n).round() % n;
  }

  void animateIcon() {
    final n = iconLoopControllers[currentIndex];

    if (n == currentlyAnimating) return;

    currentlyAnimating?.stop();

    currentlyAnimating = n;
    currentlyAnimating.repeat();
  }

  @override
  Widget build(BuildContext context) {
    // Calling this in build because it depends on the angle value.
    animateIcon();

    final children = <Widget>[], angle = _angleValue;

    // Need the rotation angle of the whole weather widget and the angle by which each condition is offset.
    var conditionAngle = angle;
    for (final condition in conditions) {
      children.add(weatherIcon(condition, conditionAngle));

      conditionAngle -= pi * 2 / conditions.length;
    }

    return Weather(
      angle: angle,
      arrowColor: widget.palette[ClockColor.weatherArrow],
      backgroundColor: widget.palette[ClockColor.weatherBackground],
      backgroundHighlightColor: widget.palette[ClockColor.weatherBackgroundHighlight],
      borderColor: widget.palette[ClockColor.border],
      shadowColor: widget.palette[ClockColor.shadow],
      petalsColor: widget.palette[ClockColor.petals],
      petalsHighlightColor: widget.palette[ClockColor.petalsHighlight],
      children: children,
    );
  }

  Widget weatherIcon(WeatherCondition condition, double angle) {
    switch (condition) {
      case WeatherCondition.cloudy:
        return Cloudy(
          animation: iconLoopControllers[conditions.indexOf(condition)],
          angle: angle,
          cloudColor: widget.palette[ClockColor.cloud],
        );
      case WeatherCondition.foggy:
        return Foggy(
          animation: iconLoopControllers[conditions.indexOf(condition)],
          angle: angle,
          fogColor: widget.palette[ClockColor.fog],
        );
      case WeatherCondition.rainy:
        return Rainy(
          animation: iconLoopControllers[conditions.indexOf(condition)],
          angle: angle,
          raindropColor: widget.palette[ClockColor.raindrop],
        );
      case WeatherCondition.snowy:
        return Snowy(
          animation: iconLoopControllers[conditions.indexOf(condition)],
          angle: angle,
          snowflakeColor: widget.palette[ClockColor.snowflake],
        );
      case WeatherCondition.sunny:
        return Sunny(
          animation: iconLoopControllers[conditions.indexOf(condition)],
          angle: angle,
          sunColor: widget.palette[ClockColor.sun],
        );
      case WeatherCondition.thunderstorm:
        return Thunderstorm(
          animation: iconLoopControllers[conditions.indexOf(condition)],
          angle: angle,
          lightningColor: widget.palette[ClockColor.lightning],
          raindropColor: widget.palette[ClockColor.raindrop],
          cloudColor: widget.palette[ClockColor.cloud],
        );
      case WeatherCondition.windy:
        return Windy(
          animation: iconLoopControllers[conditions.indexOf(condition)],
          angle: angle,
          primaryColor: widget.palette[ClockColor.windPrimary],
          secondaryColor: widget.palette[ClockColor.windSecondary],
        );
    }
    throw UnimplementedError('Missing weather icon for $condition.');
  }
}

class Weather extends MultiChildRenderObjectWidget {
  final double angle;

  final Color arrowColor, backgroundColor, backgroundHighlightColor, borderColor, shadowColor, petalsColor, petalsHighlightColor;

  Weather({
    Key key,
    @required List<Widget> children,
    @required this.angle,
    @required this.arrowColor,
    @required this.backgroundColor,
    @required this.backgroundHighlightColor,
    @required this.borderColor,
    @required this.shadowColor,
    @required this.petalsColor,
    @required this.petalsHighlightColor,
  })  : assert(angle != null),
        assert(arrowColor != null),
        assert(backgroundColor != null),
        assert(backgroundHighlightColor != null),
        assert(borderColor != null),
        assert(shadowColor != null),
        assert(petalsColor != null),
        assert(petalsHighlightColor != null),
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
      petalsColor: petalsColor,
      petalsHighlightColor: petalsHighlightColor,
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
      ..shadowColor = shadowColor
      ..petalsColor = petalsColor
      ..petalsHighlightColor = petalsHighlightColor;
  }
}

class WeatherChildrenParentData extends CompositionChildrenParentData<WeatherCondition> {
  /// [radius] and [indentationFactor] are simply passed for convenience
  double radius, indentationFactor;
}

class RenderWeather extends RenderComposition<WeatherCondition, WeatherChildrenParentData, Weather> {
  RenderWeather({
    double angle,
    Color arrowColor,
    Color backgroundColor,
    Color backgroundHighlightColor,
    Color borderColor,
    Color shadowColor,
    Color petalsColor,
    Color petalsHighlightColor,
  })  : _angle = angle,
        _arrowColor = arrowColor,
        _backgroundColor = backgroundColor,
        _backgroundHighlightColor = backgroundHighlightColor,
        _borderColor = borderColor,
        _shadowColor = shadowColor,
        _petalsColor = petalsColor,
        _petalsHighlightColor = petalsHighlightColor,
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

  Color _arrowColor, _backgroundColor, _backgroundHighlightColor, _borderColor, _shadowColor, _petalsColor, _petalsHighlightColor;

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

  /// Declares that the weather background is not a
  /// repaint boundary.
  ///
  /// This is useful because [markNeedsPaint] is called when the
  /// angle changes, i.e. when the dial rotates.
  @override
  bool get isRepaintBoundary => true;

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

  static const indentationFactor = .50;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    canvas.save();
    // Rotate the petals and background to make it appear as if the arrow
    // was the only stationary part.
    canvas.rotate(_angle);

    _drawBackground(canvas);
    canvas.drawPetals(_petalsColor, _petalsHighlightColor, _radius);

    canvas.restore();

    _drawArrow(canvas);
    canvas.drawLid(
      _backgroundColor,
      Color.lerp(_backgroundColor, _backgroundHighlightColor, 1 / 3),
      _shadowColor,
      _radius / 21,
      _radius / 31,
    );

    canvas.restore();

    for (final condition in conditions) {
      final childParentData = layoutParentData[condition];

      childParentData
        ..indentationFactor = indentationFactor
        ..radius = _radius;

      paintChild(condition);
    }
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
  final Animation<double> animation;

  RenderWeatherIcon(WeatherCondition condition, this.animation, double angle)
      : _angle = angle,
        super(condition);

  double _angle;

  set angle(double value) {
    assert(value != null);

    if (_angle == value) {
      return;
    }

    _angle = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    animation.removeListener(markNeedsPaint);

    super.detach();
  }

  WeatherCondition get condition => childType;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  double get radius => compositionData.radius;

  double get indentationFactor => compositionData.indentationFactor;

  /// Returns the section of the radius that is available to
  /// the icon, i.e. the available space vertically if the angle
  /// is 0.
  ///
  /// "rr" is supposed to abbreviate "relative radius".
  ///
  /// In some cases it makes more sense to just use [radius] for
  /// relative sizing, e.g. when declaring something like a
  /// stroke width that has to be legible.
  /// In other cases the sizing of a path depends on the actual
  /// size the icon has available instead.
  double get rr => radius * indentationFactor;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    // Translate the canvas to the center of the square.
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);

    // Clip the area of the parent (weather circle).
    context.canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius)));

    canvas.rotate(_angle);

    // Position and rotate the canvas according to the values stored in the composition data.
    final iconPosition = Offset(0, radius * (indentationFactor - 1));

    // Cannot use context.pushTransform as it modifies the layer
    // and that is not allowed when this render object is a
    // repaint boundary. See https://github.com/flutter/flutter/issues/48737.
    canvas.transform(Matrix4.translationValues(iconPosition.dx, iconPosition.dy, 0).storage);

    paintIcon(context, offset);

    canvas.restore();
  }

  /// Paints the appropriate icon.
  ///
  /// Named `paintX` because of [PaintingContext]. Information on
  /// the naming scheme I chose can be found at [ExtendedCanvas.drawPetals].
  void paintIcon(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();

    // Having the center in the middle between the tip of the arrow and the border of the circle should be good.
    canvas.translate(0, radius * -indentationFactor / 2);

    drawCondition(canvas);

    canvas.restore();
  }

  void drawCondition(Canvas canvas);

  /// Set this to debug an icon for any [WeatherCondition].
  ///
  /// `null` will disable the debug painting.
  static const WeatherCondition debugCondition = null;

  /// Paints icon in neutral orientation in big in order to easily design it.
  @override
  void debugPaint(PaintingContext context, Offset offset) {
    assert(() {
      // Leaving this as an option for now as I want to be able to come back later to improve the icons.
      if (debugCondition == null || debugCondition != condition) return true;

      final canvas = context.canvas;

      canvas.drawPaint(Paint()..color = const Color(0x72000000));

      canvas.save();
      canvas.translate(offset.dx + size.width / 2, offset.dy + size.height);
      canvas.scale(4);

      final w = size.width / 5, h = size.height / 5;
      canvas.drawRect(
          Rect.fromLTWH(w / -2, h / -2, w, h),
          Paint()
            ..color = const Color(0xffddaa00)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width / 481);
      drawCondition(canvas);

      canvas.restore();
      return true;
    }());
    super.debugPaint(context, offset);
  }
}

class Cloudy extends LeafRenderObjectWidget {
  final Animation<double> animation;

  final double angle;

  final Color cloudColor;

  Cloudy({
    Key key,
    @required this.animation,
    @required this.angle,
    @required this.cloudColor,
  })  : assert(cloudColor != null),
        assert(animation != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCloudy(
      animation: animation,
      angle: angle,
      cloudColor: cloudColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCloudy renderObject) {
    renderObject
      ..angle = angle
      ..cloudColor = cloudColor;
  }
}

class RenderCloudy extends RenderWeatherIcon {
  RenderCloudy({
    Animation<double> animation,
    double angle,
    Color cloudColor,
  })  : _cloudColor = cloudColor,
        super(WeatherCondition.cloudy, animation, angle);

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
    // Foreground cloud
    _drawAnimatedCloud(
      canvas,
      -rr / 16,
      -rr / 13.6,
      rr / 4,
      1.24,
      1 - animation.value,
    );

    // Right cloud
    _drawAnimatedCloud(
      canvas,
      rr / 6,
      rr / 5.2,
      -rr / 5,
      .75,
      (animation.value + 3 / 4) % 1,
    );

    // Big cloud
    _drawAnimatedCloud(
      canvas,
      -rr / 167,
      rr / 167,
      0,
      1.9,
      (animation.value + 1 / 4) % 1,
    );

    // Back cloud
    _drawAnimatedCloud(canvas, -rr / 4.5, -rr / 5.3, -rr / 4, .6);
  }

  void _drawAnimatedCloud(Canvas canvas, double stx, double etx, double ty, double s, [double animationValue]) {
    final sequence = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(stx), weight: 1),
      TweenSequenceItem(
        tween: Tween<double>(begin: stx, end: etx).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 4,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(etx), weight: 1),
      TweenSequenceItem(
        tween: Tween<double>(begin: etx, end: stx).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 4,
      ),
    ]);

    _drawCloud(
      canvas,
      _cloudColor,
      rr,
      sequence.transform(animationValue ?? animation.value),
      ty,
      s,
    );
  }
}

void _drawCloud(Canvas canvas, Color cloudColor, double rr, double tx, double ty, double s) {
  canvas.save();

  canvas.translate(tx, ty);
  canvas.scale(s);

  final h = rr / 4,
      w = h * 1.75,
      // The radius for the circles on the left
      // and on the right of the cloud.
      cr = h / 3.8,
      path = Path()
        ..moveTo(0, h / 2)
        ..lineTo(
          -w / 2 + cr,
          h / 2,
        )
        ..halfCircleTo(
          -w / 2 + cr * 1.2,
          h / 2 - cr * 1.8,
        )
        ..quadraticBezierTo(
          -w / 3.6,
          -h / 3.2,
          -w / 16,
          h / 2 - cr * 2.7,
        )
        ..quadraticBezierTo(
          w / 4,
          -h / 2.2,
          w / 2 - cr * 1.1,
          h / 2 - cr * 1.7,
        )
        ..halfCircleTo(
          w / 2 - cr,
          h / 2,
        )
        ..close();

  canvas.drawPath(
      path,
      Paint()
        ..color = cloudColor
        ..style = PaintingStyle.fill);

  canvas.restore();
}

class Foggy extends LeafRenderObjectWidget {
  final Animation<double> animation;

  final double angle;

  final Color fogColor;

  Foggy({
    Key key,
    @required this.animation,
    @required this.angle,
    @required this.fogColor,
  })  : assert(fogColor != null),
        assert(animation != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFoggy(
      animation: animation,
      angle: angle,
      fogColor: fogColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFoggy renderObject) {
    renderObject
      ..angle = angle
      ..fogColor = fogColor;
  }
}

class RenderFoggy extends RenderWeatherIcon {
  RenderFoggy({
    Animation<double> animation,
    double angle,
    Color fogColor,
  })  : _fogColor = fogColor,
        super(WeatherCondition.foggy, animation, angle);

  Color _fogColor;

  set fogColor(Color value) {
    assert(value != null);

    if (_fogColor == value) {
      return;
    }

    _fogColor = value;
    markNeedsPaint();
  }

  TweenSequence sequence;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    sequence = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1 / 2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1 / 2), weight: 1),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1 / 2, end: 0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -1 / 2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(-1 / 2), weight: 1),
      TweenSequenceItem(
        tween: Tween<double>(begin: -1 / 2, end: 0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]);
  }

  @override
  void drawCondition(Canvas canvas) {
    final g = rr / 14;

    // Once again, it is easier to adjust it like this afterwards.
    canvas.translate(g * .71, g * .31);
    canvas.scale(.96);

    final paint = Paint()
      ..color = _fogColor
      ..strokeWidth = g * .93
      ..strokeCap = StrokeCap.round;

    _drawLine(canvas, paint, Offset(-g * 4.5, -3 * g), Offset(0, -3 * g), g * .6, 0);
    _drawLine(canvas, paint, Offset(-g * 3, -g), Offset(g * 4, -g), g / 2, -1 / 5);
    _drawLine(canvas, paint, Offset(g * -6, g), Offset(g * 2, g), g / 3, 1 / 3);
    _drawLine(canvas, paint, Offset(g * -5, g * 3), Offset(g * 4, g * 3), g / 4, 7 / 4);
  }

  void _drawLine(Canvas canvas, Paint paint, Offset start, Offset end, double tx, double shift) {
    final addend = Offset(tx * sequence.transform((animation.value + shift) % 1), 0);

    canvas.drawLine(start + addend, end + addend, paint);
  }
}

class Rainy extends LeafRenderObjectWidget {
  final Animation<double> animation;

  final double angle;

  final int raindrops;

  final Color raindropColor;

  Rainy({
    Key key,
    @required this.animation,
    @required this.angle,
    this.raindrops = 42,
    @required this.raindropColor,
  })  : assert(raindropColor != null),
        assert(animation != null),
        super(key: key);

  @override
  RenderRainy createRenderObject(BuildContext context) {
    return RenderRainy(
      animation: animation,
      angle: angle,
      raindrops: raindrops,
      raindropColor: raindropColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderRainy renderObject) {
    renderObject
      ..angle = angle
      ..raindrops = raindrops
      ..raindropColor = raindropColor;
  }
}

class RenderRainy extends RenderWeatherIcon {
  RenderRainy({
    Animation<double> animation,
    double angle,
    int raindrops,
    Color raindropColor,
  })  : _raindrops = raindrops,
        _raindropColor = raindropColor,
        super(WeatherCondition.rainy, animation, angle);

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
    _drawRain(canvas, _raindropColor, radius, 0, _raindrops, 1.42, animationSeed: 23, animationValue: animation.value);
  }
}

void _drawRain(Canvas canvas, Color raindropColor, double radius, int randomSeed, int raindrops, double scale, {double animationValue, int animationSeed}) {
  canvas.save();
  canvas.scale(scale);

  final random = Random(randomSeed),
      animationRandom = animationSeed == null ? null : Random(animationSeed),
      raindropPaint = Paint()
        ..color = raindropColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius / 142;

  for (var i = 0; i < raindrops; i++) {
    final horizontalShift = random.nextDouble() - 1 / 2,
        verticalShift = random.nextDouble() - 1 / 2,
        heightShift = random.nextDouble(),
        start = Offset(horizontalShift * radius / 4, radius / -25 + verticalShift * radius / 5),
        path = Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(start.dx, start.dy + radius / 17 * (1 / 2 + heightShift));

    if (animationValue == null) {
      canvas.drawPath(path, raindropPaint);
      continue;
    }

    final timeShift = animationRandom.nextDouble() * 4,
        trimTween = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween<Tuple<double>>(const Tuple(0, 1)),
        weight: timeShift,
      ),
      TweenSequenceItem(
        tween: Tween<Tuple<double>>(
          begin: const Tuple<double>(0, 1),
          end: const Tuple<double>(1, 1),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Tuple<double>>(
          begin: const Tuple<double>(0, 0),
          end: const Tuple<double>(0, 1),
        ).chain(CurveTween(curve: Curves.decelerate)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Tuple<double>>(const Tuple(0, 1)),
        weight: 4 - timeShift,
      ),
    ]),
        tuple = trimTween.transform(animationValue);

    canvas.drawPath(path.trimmed(tuple.first, tuple.second), raindropPaint);
  }

  canvas.restore();
}

class Snowy extends LeafRenderObjectWidget {
  final Animation<double> animation;

  final double angle;

  final int snowflakes,

      /// How many snowflakes are lying on the ground.
      snow;

  final Color snowflakeColor;

  Snowy({
    Key key,
    @required this.animation,
    @required this.angle,
    this.snowflakes = 92,
    this.snow = 28,
    @required this.snowflakeColor,
  })  : assert(snowflakeColor != null),
        assert(animation != null),
        super(key: key);

  @override
  RenderSnowy createRenderObject(BuildContext context) {
    return RenderSnowy(
      animation: animation,
      angle: angle,
      snowflakes: snowflakes,
      snow: snow,
      snowflakeColor: snowflakeColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSnowy renderObject) {
    renderObject
      ..angle = angle
      ..snowflakes = snowflakes
      ..snow = snow
      ..snowflakeColor = snowflakeColor;
  }
}

class RenderSnowy extends RenderWeatherIcon {
  RenderSnowy({
    Animation<double> animation,
    double angle,
    int snowflakes,
    int snow,
    Color snowflakeColor,
  })  : _snowflakes = snowflakes,
        _snow = snow,
        _snowflakeColor = snowflakeColor,
        super(WeatherCondition.snowy, animation, angle);

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
    final random = Random(815174), animationRandom = Random(119);

    // Draw snowflakes
    final paint = Paint()..color = _snowflakeColor;
    for (var i = 0; i < _snowflakes; i++) {
      final verticalShift = random.nextDouble() - 1 / 2,
          horizontalShift = random.nextDouble() - 1 / 2,
          diameterShift = random.nextDouble(),
          diameter = radius / 49 * (1 + diameterShift / 2),
          position = Offset(radius / 3 * horizontalShift, -radius / 23 + radius / 4 * verticalShift),
          end = radius / 5.8;

      // Holds a sequence for the opacity and vertical position
      // of each snowflake.
      final flakeSequence = TweenSequence<Tuple<double>>([
        TweenSequenceItem(
          tween: ConstantTween(Tuple<double>(position.dy, 1)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<Tuple<double>>(
            begin: Tuple(position.dy, 1),
            end: Tuple(end, 1),
          ).chain(CurveTween(curve: Curves.easeInOut)),
          weight: 7,
        ),
        TweenSequenceItem(
          tween: Tween<Tuple<double>>(
            begin: Tuple(end, 1),
            end: Tuple(end, 0),
          ),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ConstantTween(const Tuple<double>(0, 0)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<Tuple<double>>(
            begin: Tuple(position.dy, 0),
            end: Tuple(position.dy, 1),
          ),
          weight: 3,
        ),
      ]);

      final tuple = flakeSequence.transform((animation.value + animationRandom.nextDouble()) % 1),
          animatedPaint = Paint()..color = paint.color.withOpacity(paint.color.opacity * tuple.second),
          animatedPosition = Offset(position.dx, tuple.first),
          circle = Rect.fromCircle(center: animatedPosition, radius: diameter / 2);

      canvas.drawOval(circle, animatedPaint);
    }

    // Draw some laying on the ground
    for (var i = 0; i < _snow; i++) {
      final verticalShift = random.nextDouble(), horizontalShift = random.nextDouble() - 1 / 2, diameterShift = random.nextDouble(), diameter = radius / 33 * (1 + diameterShift / 2);

      canvas.drawOval(Rect.fromCircle(center: Offset(radius / 3.2 * horizontalShift, radius / 6.2 + radius / 42 * verticalShift), radius: diameter / 2), paint);
    }
  }
}

class Sunny extends LeafRenderObjectWidget {
  final Animation<double> animation;

  final double angle;

  final int sunRays;

  final Color sunColor;

  Sunny({
    Key key,
    @required this.animation,
    @required this.angle,
    this.sunRays = 12,
    @required this.sunColor,
  })  : assert(sunColor != null),
        assert(animation != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSunny(
      animation: animation,
      angle: angle,
      sunRays: sunRays,
      sunColor: sunColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSunny renderObject) {
    renderObject
      ..angle = angle
      ..sunRays = sunRays
      ..sunColor = sunColor;
  }
}

class RenderSunny extends RenderWeatherIcon {
  RenderSunny({
    Animation<double> animation,
    double angle,
    int sunRays,
    Color sunColor,
  })  : _sunRays = sunRays,
        _sunColor = sunColor,
        super(WeatherCondition.sunny, animation, angle);

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
    canvas.save();

    // Animation loop
    canvas.rotate(pi * 2 * animation.value / _sunRays);

    canvas.scale(1.17);

    final paint = Paint()
      ..color = _sunColor
      ..strokeWidth = radius / 124;

    canvas.drawOval(Rect.fromCircle(center: Offset.zero, radius: radius / 9), paint);

    for (var i = 0; i < _sunRays; i++) {
      final direction = pi * 2 / _sunRays * i;
      canvas.drawLine(Offset.fromDirection(direction, radius / 8), Offset.fromDirection(direction, radius / 6), paint);
    }

    canvas.restore();
  }
}

class Thunderstorm extends LeafRenderObjectWidget {
  final Animation<double> animation;

  final double angle;

  final int raindrops;

  final Color lightningColor, raindropColor, cloudColor;

  Thunderstorm({
    Key key,
    @required this.animation,
    @required this.angle,
    this.raindrops = 13,
    @required this.lightningColor,
    @required this.raindropColor,
    @required this.cloudColor,
  })  : assert(lightningColor != null),
        assert(raindropColor != null),
        assert(cloudColor != null),
        assert(animation != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderThunderstorm(
      animation: animation,
      angle: angle,
      raindrops: raindrops,
      lightningColor: lightningColor,
      raindropColor: raindropColor,
      cloudColor: cloudColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderThunderstorm renderObject) {
    renderObject
      ..angle = angle
      ..raindrops = raindrops
      ..lightningColor = lightningColor
      ..raindropColor = raindropColor
      ..cloudColor = cloudColor;
  }
}

class RenderThunderstorm extends RenderWeatherIcon {
  RenderThunderstorm({
    Animation<double> animation,
    double angle,
    int raindrops,
    Color lightningColor,
    Color raindropColor,
    Color cloudColor,
  })  : _raindrops = raindrops,
        _lightningColor = lightningColor,
        _raindropColor = raindropColor,
        _cloudColor = cloudColor,
        super(WeatherCondition.thunderstorm, animation, angle);

  int _raindrops;

  set raindrops(int value) {
    assert(value != null);

    if (_raindrops == value) {
      return;
    }

    _raindrops = value;
    markNeedsPaint();
  }

  Color _lightningColor, _raindropColor, _cloudColor;

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

  set cloudColor(Color value) {
    assert(value != null);

    if (_cloudColor == value) {
      return;
    }

    _cloudColor = value;
    markNeedsPaint();
  }

  TweenSequence<double> lightningSequence;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    lightningSequence = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: 21,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: .9,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: .9,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: .84,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: .84,
          end: .1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: 5,
      ),
    ]);
  }

  @override
  void drawCondition(Canvas canvas) {
    // Draw lightning
    canvas.save();
    canvas.translate(-rr / 18, rr / -6.7);

    final l = rr / 9.7,
        lightningPath = Path()
          ..moveTo(0, 0)
          ..lineTo(-l, 0)
          ..lineTo(-1.3 * l, 2 * l)
          ..lineTo(-.6 * l, 2 * l)
          ..lineTo(-.86 * l, 3.75 * l)
          ..lineTo(0, 1.5 * l)
          ..lineTo(-.45 * l, 1.5 * l)
          ..lineTo(0, 0)
          ..close();
    canvas.drawPath(
        lightningPath,
        Paint()
          ..color = _lightningColor.withOpacity(min(1, lightningSequence.transform(animation.value)))
          ..style = PaintingStyle.fill);

    canvas.restore();

    // Draw raindrops
    canvas.save();

    canvas.translate(0, rr / 7);
    _drawRain(canvas, _raindropColor, radius, 454, _raindrops, 1, animationSeed: 2, animationValue: animation.value);

    canvas.restore();

    canvas.save();
    // The cloud in here should be mirrored horizontally.
    canvas.scale(-1, 1);

    _drawCloud(
      canvas,
      _cloudColor,
      rr,
      0,
      -rr / 4,
      1.7,
    );

    canvas.restore();
  }
}

class Windy extends LeafRenderObjectWidget {
  final Animation<double> animation;

  final double angle;

  final Color primaryColor, secondaryColor;

  Windy({
    Key key,
    @required this.animation,
    @required this.angle,
    @required this.primaryColor,
    @required this.secondaryColor,
  })  : assert(primaryColor != null),
        assert(secondaryColor != null),
        assert(animation != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWindy(
      animation: animation,
      angle: angle,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderWindy renderObject) {
    renderObject
      ..angle = angle
      ..primaryColor = primaryColor
      ..secondaryColor = secondaryColor;
  }
}

class RenderWindy extends RenderWeatherIcon {
  RenderWindy({
    Animation<double> animation,
    double angle,
    Color primaryColor,
    Color secondaryColor,
  })  : _primaryColor = primaryColor,
        _secondaryColor = secondaryColor,
        super(WeatherCondition.windy, animation, angle);

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
    canvas.save();

    // Primary wind symbol
    _drawWind(canvas, _primaryColor, -rr / 7, rr / 36, .83, 2, 1.8, 1);

    // Upper wind symbol
    _drawWind(canvas, _secondaryColor, rr / -2.7, rr / -4.4, .69, 2, 1.8, 1);

    // Lower wind symbol
    _drawWind(canvas, _secondaryColor, rr / -3.5, rr / 3.8, .61, 1, 1, 1);

    canvas.restore();
  }

  void _drawWind(Canvas canvas, Color c, double tx, double ty, double s, double l1, double l2, double l3) {
    canvas.save();
    canvas.translate(tx, ty);
    canvas.scale(s);

    final mf = rr / 5, hd = mf / 4;

    // Draw wind symbol consisting of four paths
    final paint = Paint()
          ..color = c
          ..strokeWidth = radius / 92
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
