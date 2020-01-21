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
  temperature,
  temperatureMax,
  temperatureMin,
  bracket,
  bracketHighlight,
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

  /// The digital time is on a different part of the background,
  /// i.e. on the goo and therefore might need a different text
  /// color.
  digitalTimeText,

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

  /// Colors used for [ExtendedCanvas.drawPetals].
  petals,
  petalsHighlight,
}

/// A controller for the palette for all colors used in the clock face.
///
/// The actual palette values are stored as `Map<ClockColor, Color>`
/// ([Map], [ClockColor], & [Color]) and this [StatefulWidget] controls
/// which palette is currently shown.
///
/// Predefined palettes are [vibrantLight] and [subtleLight] or [vibrantDark] and [subtleDark],
/// which override values in [light]/[dark] respectively, which override values in [base].
class Palette extends StatefulWidget {
  static _PaletteState of(BuildContext context) =>
      context.findAncestorStateOfType<_PaletteState>();

  static const Map<ClockColor, Color> base = {
    // Temperature colors are supposed to match
    // the colors that a temperature makes us think of.
    ClockColor.temperature: Color(0xde6ab7ff),
    ClockColor.temperatureMax: Color(0x9cff3a4b),
    ClockColor.temperatureMin: Color(0xae2a42ff),

    // Weather icons resemble real life colors.
    ClockColor.cloud: Color(0xcbc1beba),
    ClockColor.fog: Color(0xc5cdc8be),
    ClockColor.raindrop: Color(0xdda1c6cc),
    ClockColor.snowflake: Color(0xbbfffafa),
    ClockColor.sun: Color(0xfffcd440),
    ClockColor.lightning: Color(0xfffdd023),
    ClockColor.windPrimary: Color(0xff96c4e8),
    ClockColor.windSecondary: Color(0xff008abf),
    ClockColor.shadow: Color(0xff000000),

    // Based on some metal, works everywhere.
    ClockColor.brad: Color(0xff898984),
    ClockColor.bradHighlight: Color(0xff43464b),
    ClockColor.bracket: Color(0xff87898c),
    ClockColor.bracketHighlight: Color(0xffe0e1e2),

    // Dots on the ball
    ClockColor.dotsIdleColor: Color(0x90e5e4e2),
    ClockColor.dotsPrimedColor: Color(0xc3e00201),
    ClockColor.dotsDisengagedColor: Color(0x804682b4),
  },
      light = {
    ClockColor.text: Color(0xcd000000),
    ClockColor.border: Color(0xff000000),
    ClockColor.petalsHighlight: Color(0xffffffff),
    ClockColor.analogTimeBackgroundHighlight: Color(0xffffffff),

    // These look too sad in light mode otherwise
    ClockColor.cloud: Color(0xebc1beba),
    ClockColor.fog: Color(0xe5dfdad0),
  },
      vibrantLight = {
    // Background
    ClockColor.background: Color(0xffae8c5f),
    ClockColor.goo: Color(0xff35271c),

    // Component backgrounds
    ClockColor.analogTimeBackground: Color(0xffe2ca5c),
    ClockColor.weatherBackground: Color(0xffaa8630),
    ClockColor.weatherBackgroundHighlight: Color(0xfffbf6ce),
    ClockColor.thermometerBackgroundPrimary: Color(0xffaa8630),
    ClockColor.thermometerBackgroundSecondary: Color(0xfff8f1a3),
    ClockColor.slidePrimary: Color(0xff94704e),
    ClockColor.slideSecondary: Color(0xff392818),

    // Smaller elements
    ClockColor.petals: Color(0xffbab33c),
    ClockColor.ballPrimary: Color(0xffc9855e),
    ClockColor.ballSecondary: Color(0xff2b2100),
    ClockColor.digitalTimeText: Color(0xfff3f0c7),

    // Thermometer
    ClockColor.thermometerTube: Color(0xffffe3d1),
    ClockColor.thermometerMount: Color(0xff836d2e),

    // Analog clock
    ClockColor.hourHand: Color(0xff3a1009),
    ClockColor.minuteHand: Color(0xff000000),
    ClockColor.secondHand: Color(0xff09103a),

    // Weather dial
    ClockColor.weatherArrow: Color(0xff3D0C02),
    ClockColor.raindrop: Color(0xbf8cdfe8),
    ClockColor.windPrimary: Color(0xef99edf3),
    ClockColor.windSecondary: Color(0xff1c70b7),
  },
      subtleLight = {
    // Background
    ClockColor.background: Color(0xffb2beb5),
    ClockColor.goo: Color(0xff828e84),

    // Component backgrounds
    ClockColor.analogTimeBackground: Color(0xffdcddd8),
    ClockColor.weatherBackground: Color(0xffdcddd8),
    ClockColor.weatherBackgroundHighlight: Color(0xfffafafa),
    ClockColor.thermometerBackgroundPrimary: Color(0xffffffff),
    ClockColor.thermometerBackgroundSecondary: Color(0xffc6c8c5),
    ClockColor.slideSecondary: Color(0xffcdcbce),
    ClockColor.slidePrimary: Color(0xff9d9e98),

    // Smaller elements
    ClockColor.ballPrimary: Color(0xff828e84),
    ClockColor.ballSecondary: Color(0xff2a3731),
    ClockColor.petals: Color(0xdd000000),
    ClockColor.digitalTimeText: Color(0xcd000000),

    // Thermometer
    ClockColor.thermometerMount: Color(0xff919c9f),
    ClockColor.thermometerTube: Color(0xffededed),

    // Analog clock
    ClockColor.hourHand: Color(0xff232323),
    ClockColor.minuteHand: Color(0xff1a1a1a),
    ClockColor.secondHand: Color(0xff000000),

    // Weather dial
    ClockColor.weatherArrow: Color(0xff121314),
    ClockColor.sun: Color(0xffe4bd29),
  },
      dark = {
    // Text
    ClockColor.text: Color(0xb3ffffff),
    ClockColor.digitalTimeText: Color(0xb3ffffff),

    // Misc
    ClockColor.border: Color(0xffffffff),
    ClockColor.thermometerTube: Color(0xc1d9d9d9),
  },
      vibrantDark = {
    // Background
    ClockColor.background: Color(0xff121212),
    ClockColor.goo: Color(0xff000010),

    // Component backgrounds
    ClockColor.thermometerBackgroundPrimary: Color(0xff2f2f4f),
    ClockColor.thermometerBackgroundSecondary: Color(0xff03031f),
    ClockColor.analogTimeBackground: Color(0xff980036),
    ClockColor.analogTimeBackgroundHighlight: Color(0xffca1f7b),
    ClockColor.weatherBackground: Color(0xff4b0082),
    ClockColor.weatherBackgroundHighlight: Color(0xff7f00ff),

    // other elements
    ClockColor.petals: Color(0xff483d8b),
    ClockColor.petalsHighlight: Color(0xff9f79ee),
    ClockColor.ballPrimary: Color(0xff42426f),
    ClockColor.ballSecondary: Color(0xff162252),
    ClockColor.slidePrimary: Color(0xff200460),
    ClockColor.slideSecondary: Color(0xff4d4870),

    // Thermometer
    ClockColor.thermometerMount: Color(0xff525252),
    ClockColor.temperature: Color(0xce3a97df),
    ClockColor.temperatureMax: Color(0x8cdf1a2b),
    ClockColor.temperatureMin: Color(0xae071fdd),

    // Analog clock
    ClockColor.hourHand: Color(0xffcfbdff),
    ClockColor.minuteHand: Color(0xfff0e0ff),
    ClockColor.secondHand: Color(0xffc0aefd),

    // Weather dial
    ClockColor.weatherArrow: Color(0xffcdcded),
  },
      subtleDark = {
    // Background
    ClockColor.background: Color(0xff050505),
    ClockColor.goo: Color(0xff000000),

    // Component backgrounds
    ClockColor.analogTimeBackground: Color(0xff333333),
    ClockColor.analogTimeBackgroundHighlight: Color(0xff646464),
    ClockColor.weatherBackground: Color(0xff343434),
    ClockColor.weatherBackgroundHighlight: Color(0xff454545),
    ClockColor.thermometerBackgroundPrimary: Color(0xff343434),
    ClockColor.thermometerBackgroundSecondary: Color(0xff0e0e0e),
    ClockColor.slideSecondary: Color(0xff333333),
    ClockColor.slidePrimary: Color(0xff101010),

    // Smaller elements
    ClockColor.ballPrimary: Color(0xff6c6c6c),
    ClockColor.ballSecondary: Color(0xff080808),
    ClockColor.petals: Color(0xffffffff),
    ClockColor.petalsHighlight: Color(0x7f212121),

    // Thermometer
    ClockColor.thermometerMount: Color(0xff525252),
    ClockColor.temperature: Color(0xce3a97df),
    ClockColor.temperatureMax: Color(0x8cdf1a2b),
    ClockColor.temperatureMin: Color(0xae071fdd),

    // Analog clock
    ClockColor.hourHand: Color(0xffc1c1c1),
    ClockColor.minuteHand: Color(0xffefefef),
    ClockColor.secondHand: Color(0xffafafaf),

    // Weather dial
    ClockColor.weatherArrow: Color(0xff979797),
  };

  final Widget Function(BuildContext context, Map<ClockColor, Color> palette)
      builder;

  const Palette({
    @required this.builder,
  }) : assert(builder != null);

  @override
  _PaletteState createState() => _PaletteState();
}

/// The modes determine which palette in the given theme (dark or light) is shown.
///
/// This is controlled by the [paletteMode] constant.
enum PaletteMode {
  vibrant,
  subtle,
  adaptive,
}

Map<ClockColor, Color> resolvePalette(Brightness brightness, bool vibrant) {
  final palette = Map.of(Palette.base);

  if (brightness == Brightness.light) {
    palette.addAll(Palette.light);

    switch (paletteMode) {
      case PaletteMode.vibrant:
        palette.addAll(Palette.vibrantLight);
        break;
      case PaletteMode.subtle:
        palette.addAll(Palette.subtleLight);
        break;
      case PaletteMode.adaptive:
        if (vibrant) {
          palette.addAll(Palette.vibrantLight);
        } else {
          palette.addAll(Palette.subtleLight);
        }
        break;
    }
  } else {
    palette.addAll(Palette.dark);

    switch (paletteMode) {
      case PaletteMode.vibrant:
        palette.addAll(Palette.vibrantDark);
        break;
      case PaletteMode.subtle:
        palette.addAll(Palette.subtleDark);
        break;
      case PaletteMode.adaptive:
        if (vibrant) {
          palette.addAll(Palette.vibrantDark);
        } else {
          palette.addAll(Palette.subtleDark);
        }
        break;
    }
  }

  return palette;
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

  Map<ClockColor, Color> resolve(BuildContext context) =>
      resolvePalette(Theme.of(context).brightness, _vibrant);

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, resolve(context));
  }
}
