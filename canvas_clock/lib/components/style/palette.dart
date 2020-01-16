import 'dart:ui';

import 'package:canvas_clock/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ClockColor {
  /// This is also used for tick marks or lines on the
  /// analog clock and thermometer.
  text,

  /// Used to outline some components.
  border,
  ballPrimary,
  ballSecondary,
  thermometerBackgroundPrimary,
  thermometerBackgroundSecondary,
  brad,

  /// Highlight colors here are used to resemble a shining material,
  /// i.e. some parts of the object should appear closer to the light source
  /// and e.g. metal will be lighter in those areas.
  bradHighlight,
  thermometerTube,
  thermometerMount,
  thermometerTemperature,
  thermometerTemperatureMax,
  thermometerTemperatureMin,
  thermometerBracket,
  thermometerBracketHighlight,
  weatherArrow,
  weatherBackground,
  weatherBackgroundHighlight,
  cloud,
  fog,
  raindrop,
  snowflake,
  sun,
  lightning,
  windPrimary,
  windSecondary,
  background,
  goo,
  analogTimeBackground,
  analogTimeBackgroundHighlight,
  hourHand,
  minuteHand,
  secondHand,
  shadow,

  /// The two dots that are drawn onto the ball
  /// in order to always show rotation turned
  /// into more than that and also have a signaling
  /// function. They show what state the ball is
  /// currently in.
  dotsIdleColor,
  dotsPrimedColor,
  dotsDisengagedColor,

  /// These form a linear gradient.
  slidePrimary,
  slideSecondary,
}

/// A controller for the palette for all colors used in the clock face.
///
/// The actual palette values are stored as `Map<ClockColor, Color>`
/// ([Map], [ClockColor], & [Color]) and this [StatefulWidget] controls
/// which palette is currently shown.
///
/// Predefined palettes are [vibrantLight] and [subtleLight] or [vibrantDark] and [subtleDark].
class Palette extends StatefulWidget {
  static _PaletteState of(BuildContext context) => context.findAncestorStateOfType<_PaletteState>();

  static const Map<ClockColor, Color> base = {
    ClockColor.text: Color(0xcd000000),
    ClockColor.ballPrimary: Color(0xffd3d3ff),
    ClockColor.ballSecondary: Color(0xff9a9aff),
    ClockColor.thermometerTube: Color(0xffffe3d1),
    ClockColor.thermometerMount: Color(0xffa38d1c),
    ClockColor.thermometerBackgroundPrimary: Color(0xffcc9933),
    ClockColor.thermometerBackgroundSecondary: Color(0xffc9bd6c),
    ClockColor.border: Color(0xff000000),
    ClockColor.brad: Color(0xff898984),
    ClockColor.bradHighlight: Color(0xff43464b),
    ClockColor.thermometerTemperature: Color(0xde6ab7ff),
    ClockColor.thermometerTemperatureMax: Color(0x9cff3a4b),
    ClockColor.thermometerTemperatureMin: Color(0xae2a42ff),
    ClockColor.thermometerBracket: Color(0xff87898c),
    ClockColor.thermometerBracketHighlight: Color(0xffe0e1e2),
    ClockColor.weatherArrow: Color(0xffffddbb),
    ClockColor.cloud: Color(0xcbc1beba),
    ClockColor.fog: Color(0xc5cdc8be),
    ClockColor.raindrop: Color(0xdda1c6cc),
    ClockColor.snowflake: Color(0xbbfffafa),
    ClockColor.sun: Color(0xfffcd440),
    ClockColor.lightning: Color(0xfffdd023),
    ClockColor.windPrimary: Color(0xff96c4e8),
    ClockColor.windSecondary: Color(0xff008abf),
    ClockColor.background: Color(0xffffe312),
    ClockColor.goo: Color(0xffff4683),
    ClockColor.hourHand: Color(0xff3a1009),
    ClockColor.minuteHand: Color(0xff000000),
    ClockColor.secondHand: Color(0xff09103a),
    ClockColor.shadow: Color(0xff000000),
    ClockColor.dotsIdleColor: Color(0xa0e5e4e2),
    ClockColor.dotsPrimedColor: Color(0xc3e00201),
    ClockColor.dotsDisengagedColor: Color(0xa04682b4),
    ClockColor.weatherBackground: Color(0xff7c4a5e),
    ClockColor.weatherBackgroundHighlight: Color(0xffffffff),
    ClockColor.analogTimeBackground: Color(0xffeaffd8),
    ClockColor.analogTimeBackgroundHighlight: Color(0xffffffff),
    ClockColor.slidePrimary: Color(0xffefdecd),
    ClockColor.slideSecondary: Color(0xff855e42),
  },
      baseLight = {},
      baseDark = {
    ClockColor.text: Color(0xb3ffffff),
    ClockColor.background: Color(0xff121212),
    ClockColor.goo: Color(0xff301934),
    ClockColor.thermometerBackgroundSecondary: Color(0xff654321),
    ClockColor.thermometerBackgroundPrimary: Color(0xff3b5055),
  },
      vibrantLight = {},
      vibrantDark = {},
      subtleLight = {
    // Test values todo
    ClockColor.background: Color(0xff8b4513),
    ClockColor.thermometerBackgroundSecondary: Colors.greenAccent,
    ClockColor.goo: Color(0xff73bad9),
  },
      subtleDark = {};

  final Widget Function(BuildContext context, Map<ClockColor, Color> palette) builder;

  const Palette({
    @required this.builder,
  }) : assert(builder != null);

  @override
  _PaletteState createState() => _PaletteState();
}

class _PaletteState extends State<Palette> {
  bool _vibrant;

  @override
  void initState() {
    super.initState();

    _vibrant = true;
  }

  set vibrant(bool value) {
    if (_vibrant == value) return;

    setState(() {
      _vibrant = value;
    });
  }

  bool get vibrant => _vibrant;

  Map<ClockColor, Color> resolve(BuildContext context) {
    final palette = Map.of(Palette.base);

    if (Theme.of(context).brightness == Brightness.light) {
      palette.addAll(Palette.baseLight);

      if (forceVibrantPalette ?? _vibrant) {
        palette.addAll(Palette.vibrantLight);
      } else {
        palette.addAll(Palette.subtleLight);
      }
    } else {
      palette.addAll(Palette.baseDark);

      if (forceVibrantPalette ?? _vibrant) {
        palette.addAll(Palette.vibrantDark);
      } else {
        palette.addAll(Palette.subtleDark);
      }
    }

    return palette;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, resolve(context));
  }
}
