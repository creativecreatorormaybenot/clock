import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:canvas_clock/clock.dart';

/// This takes care of animating between different [palette]s,
/// which works very well because [Color.lerp], i.e. [ColorTween],
/// exists.
class AnimatedClock extends ImplicitlyAnimatedWidget {
  final ClockModel model;

  /// Color palette for all clock components managed by [Palette].
  ///
  /// You can define your own palette as well by creating a
  /// `Map<ClockColor, Color>` and assigning a color for each key.
  /// This is the only top-level adjustment because I did not
  /// feel the need to expose more as all the components of the clock
  /// can easily be modified inside of [Clock], i.e. in the
  /// [State.build] method of its state.
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
      for (final entry in end.entries)
        entry.key: Color.lerp(begin[entry.key], end[entry.key], t),
    };
  }
}

class _AnimatedClockState extends AnimatedWidgetBaseState<AnimatedClock> {
  ColorPaletteTween _paletteTween;

  @override
  void forEachTween(visitor) {
    _paletteTween = visitor(
            _paletteTween,
            widget.palette,
            (value) =>
                ColorPaletteTween(begin: value as Map<ClockColor, Color>))
        as ColorPaletteTween;
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
