import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:canvas_clock/clock.dart';

const waveDuration = Duration(minutes: 1), waveCurve = Curves.easeInOut;

double waveProgress(DateTime time) => 1 / waveDuration.inSeconds * time.second;

class Background extends LeafRenderObjectWidget {
  final Animation<double> animation, analogTimeBounceAnimation;

  final Color ballColor, groundColor, gooColor, analogTimeComponentColor, weatherComponentColor, temperatureComponentColor;

  const Background({
    Key key,
    @required this.animation,
    @required this.analogTimeBounceAnimation,
    @required this.ballColor,
    @required this.groundColor,
    @required this.gooColor,
    @required this.analogTimeComponentColor,
    @required this.weatherComponentColor,
    @required this.temperatureComponentColor,
  })  :
        assert(animation != null),
        assert(analogTimeBounceAnimation != null),
        assert(ballColor != null),
        assert(groundColor != null),
        assert(gooColor != null),
        assert(analogTimeComponentColor != null),
        assert(weatherComponentColor != null),
        assert(temperatureComponentColor != null),
        super(key: key);

  @override
  RenderBackground createRenderObject(BuildContext context) {
    return RenderBackground(
      animation: animation,
      analogTimeBounceAnimation: analogTimeBounceAnimation,
      ballColor: ballColor,
      groundColor: groundColor,
      gooColor: gooColor,
      analogTimeComponentColor: analogTimeComponentColor,
      weatherComponentColor: weatherComponentColor,
      temperatureComponentColor: temperatureComponentColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderBackground renderObject) {
    renderObject
      ..ballColor = ballColor
      ..groundColor = groundColor
      ..gooColor = gooColor
      ..analogTimeComponentColor = analogTimeComponentColor
      ..weatherComponentColor = weatherComponentColor
      ..temperatureComponentColor = temperatureComponentColor;
  }
}

class BackgroundParentData extends ClockChildrenParentData {
  Map<ClockComponent, Rect> _rects;

  void addRect(ClockComponent component, Offset offset, Size size) {
    _rects[component] = offset & size;
  }

  Rect rectOf(ClockComponent component) {
    final rect = _rects[component];
    assert(rect != null, 'No $Rect was provided for $component. If the rect of this child should be accessible from $childType, this needs to be changed in $RenderCompositedClock.');
    return rect;
  }

  /// Needs to be called before calling [addRect] or [rectOf].
  void clearRects() {
    _rects = {};
  }

  Offset analogTimeBounce;
}

class RenderBackground extends RenderCompositionChild<ClockComponent, BackgroundParentData> {
  final Animation<double> animation, analogTimeBounceAnimation;

  RenderBackground({
    this.animation,
    this.analogTimeBounceAnimation,
    Color ballColor,
    Color groundColor,
    Color gooColor,
    Color analogTimeComponentColor,
    Color weatherComponentColor,
    Color temperatureComponentColor,
  })  : _ballColor = ballColor,
        _groundColor = groundColor,
        _gooColor = gooColor,
        _analogTimeComponentColor = analogTimeComponentColor,
        _weatherComponentColor = weatherComponentColor,
        _temperatureComponentColor = temperatureComponentColor,
        super(ClockComponent.background);

  Color _ballColor, _groundColor, _gooColor, _analogTimeComponentColor, _weatherComponentColor, _temperatureComponentColor;

  set ballColor(Color value) {
    assert(value != null);

    if (_ballColor == value) {
      return;
    }

    _ballColor = value;
    markNeedsPaint();
  }

  set groundColor(Color value) {
    assert(value != null);

    if (_groundColor == value) {
      return;
    }

    _groundColor = value;
    markNeedsPaint();
  }

  set gooColor(Color value) {
    assert(value != null);

    if (_gooColor == value) {
      return;
    }

    _gooColor = value;
    markNeedsPaint();
  }

  set analogTimeComponentColor(Color value) {
    assert(value != null);

    if (_analogTimeComponentColor == value) {
      return;
    }

    _analogTimeComponentColor = value;
    markNeedsPaint();
  }

  set weatherComponentColor(Color value) {
    assert(value != null);

    if (_weatherComponentColor == value) {
      return;
    }

    _weatherComponentColor = value;
    markNeedsPaint();
  }

  set temperatureComponentColor(Color value) {
    assert(value != null);

    if (_temperatureComponentColor == value) {
      return;
    }

    _temperatureComponentColor = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData.hasSemanticsInformation = false;

    animation.addListener(markNeedsPaint);
    analogTimeBounceAnimation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    animation.removeListener(markNeedsPaint);
    analogTimeBounceAnimation.removeListener(markNeedsPaint);

    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // Do not need to clip here because CompositedClock already clips the canvas.

    final gooArea = Rect.fromLTWH(
      // Infinite width and height ensure that the indentations of the goo caused by components will always consider the complete object, even if some of it is out of view.
      // Using maxFinite because negativeInfinity for the left value throws NaN errors.
      -double.maxFinite,
      size.height / 2 + (animation.value - 1 / 2) * size.height / 5,
      double.infinity,
      double.maxFinite,
    ),
        components = [
      compositionData.rectOf(ClockComponent.weather),
      compositionData.rectOf(ClockComponent.temperature),
      // The glow of the clock should be rendered after the other two components.
      compositionData.rectOf(ClockComponent.analogTime)
          // The background animates depending on the analog time's position.
          .shift(compositionData.analogTimeBounce * analogTimeBounceAnimation.value),
    ],
        componentColors = [
      _weatherComponentColor,
      _temperatureComponentColor,
      _analogTimeComponentColor,
    ],
        componentsInGoo = components.where((rect) => rect.overlaps(gooArea)).map((rect) => gooArea.intersect(rect)).toList();

    final canvas = context.canvas;

    canvas.save();
    // Translate to upper left corner of the clock's area.
    canvas.translate(offset.dx, offset.dy);

    // This path is supposed to represent the goo being indented by the components, which is achieved by adding Bézier curves.
    final cut = Path()..moveTo(0, gooArea.top);

    componentsInGoo.sort((a, b) => a.left.compareTo(b.left));

    // Interpolation between paths is not currently possible (see https://github.com/flutter/flutter/issues/12043),
    // hence, my solution is simply merging the rects if they overlap, which does not produce a visually pleasing
    // effect, especially because of the harsh transition, but it is better than having points on the curve that
    // do not work together, causing some parts to wrap back and forth.
    final rects = [];
    Rect previous;
    for (var i = 0; i <= componentsInGoo.length; i++) {
      if (i == componentsInGoo.length) {
        rects.add(previous);
        break;
      }

      final rect = componentsInGoo[i];

      if (previous == null) {
        previous = rect;
        continue;
      }

      if (previous.overlaps(rect)) {
        previous = previous.expandToInclude(rect);
        continue;
      }

      rects.add(previous);
      previous = rect;
    }

    for (var i = 0; i < rects.length; i++) {
      final rect = rects[i];

      cut
        ..cubicTo(
          rect.centerLeft.dx,
          rect.centerLeft.dy,
          rect.bottomLeft.dx,
          rect.bottomLeft.dy,
          rect.bottomCenter.dx,
          rect.bottomCenter.dy,
        )
        ..cubicTo(
          rect.bottomRight.dx,
          rect.bottomRight.dy,
          rect.centerRight.dx,
          rect.centerRight.dy,
          i == rects.length - 1 ? size.width : (rect.right + rects[i + 1].left) / 2,
          i == rects.length - 1 ? gooArea.top : (rect.center.dy + rects[i + 1].center.dy) / 2,
        );
    }

    cut.lineTo(size.width, gooArea.top);

    final upperPath = Path()
      ..extendWithPath(cut, Offset.zero)
      // Line to top right, then top left, and then back to start to fill whole upper area.
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(
        upperPath,
        Paint()
          ..color = _groundColor
          ..style = PaintingStyle.fill);

    // Draw a kind of glow about the given components
    for (var i = 0; i < components.length; i++) {
      final component = components[i], rect = Rect.fromCenter(center: component.center, width: component.width * 7 / 4, height: component.height * 7 / 4);

      final color = componentColors[i],
          paint = Paint()
            ..shader = ui.Gradient.radial(
              component.center,
              component.shortestSide * 7 / 8,
              [
                color,
                // It is important that the target color has no opacity
                // because the different gradient otherwise interfere.
                _groundColor.withOpacity(0),
              ],
            );

      canvas.drawOval(rect, paint);
    }

    final lowerPath = Path()
      ..extendWithPath(cut, Offset.zero)
      // Line to bottom right, then bottom left, and then back to start to fill whole lower area.
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        lowerPath,
        Paint()
          ..color = _gooColor
          ..style = PaintingStyle.fill);

    canvas.restore();
  }
}
