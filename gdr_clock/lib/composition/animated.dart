import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';

/// This takes care of animating between different [palette]s,
/// which works very well because [Color.lerp], i.e. [ColorTween],
/// exists.
class AnimatedClock extends ImplicitlyAnimatedWidget {
  final ClockModel model;

  final Map<ClockColor, Color> palette;

  const AnimatedClock({
    Key key,
    Curve curve = Curves.linear,
    Duration duration = kThemeAnimationDuration,
    @required this.model,
    @required this.palette,
  })  : assert(model != null),
        assert(palette != null),
        super(key: key, curve: curve, duration: duration);

  @override
  _AnimatedClockState createState() {
    return _AnimatedClockState();
  }
}

class ColorPaletteTween extends Tween<Map<ClockColor, Color>> {
  ColorPaletteTween({
    Map<ClockColor, Color> begin,
    Map<ClockColor, Color> end,
  }) : super(begin: begin, end: end);

  @override
  Map<ClockColor, Color> lerp(double t) {
    return <ClockColor, Color>{
      for (final entry in end.entries) entry.key: Color.lerp(begin[entry.key], end[entry.key], t),
    };
  }
}

class _AnimatedClockState extends AnimatedWidgetBaseState<AnimatedClock> {
  ColorPaletteTween _paletteTween;

  @override
  void forEachTween(visitor) {
    _paletteTween = visitor(_paletteTween, widget.palette, (value) => ColorPaletteTween(begin: value as Map<ClockColor, Color>)) as ColorPaletteTween;
    assert(_paletteTween != null);
  }

  @override
  Widget build(BuildContext context) {
    return Clock(
      model: widget.model,
      palette: _paletteTween.evaluate(animation),
    );
  }
}
