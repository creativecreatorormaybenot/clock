import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';
import 'package:gdr_clock/main.dart';

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
}

Map<ClockColor, Color> resolvePalette(BuildContext context) {
  final palette = Map.of(Clock.basePalette);

  if (Theme.of(context).brightness == Brightness.light) {
    palette.addAll(Clock.baseLightPalette);

    if (useVibrantPalette) {
      palette.addAll(Clock.vibrantLightPalette);
    } else {
      palette.addAll(Clock.subtleLightPalette);
    }
  } else {
    palette.addAll(Clock.baseDarkPalette);

    if (useVibrantPalette) {
      palette.addAll(Clock.vibrantDarkPalette);
    } else {
      palette.addAll(Clock.subtleDarkPalette);
    }
  }

  return palette;
}

class Clock extends StatefulWidget {
  static const Map<ClockColor, Color> basePalette = {
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
    ClockColor.weatherBackground: Color(0xff2c6aee),
    ClockColor.weatherBackgroundHighlight: Color(0xffffffff),
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
    ClockColor.analogTimeBackground: Color(0xffeaffd8),
    ClockColor.analogTimeBackgroundHighlight: Color(0xffffffff),
    ClockColor.hourHand: Color(0xff3a1009),
    ClockColor.minuteHand: Color(0xff000000),
    ClockColor.secondHand: Color(0xff09103a),
    ClockColor.shadow: Color(0xff000000),
  },
      baseLightPalette = {},
      baseDarkPalette = {
    // Test values todo
    ClockColor.text: Color(0xff424242),
    ClockColor.background: Color(0xffffffff),
  },
      vibrantLightPalette = {},
      vibrantDarkPalette = {},
      subtleLightPalette = {},
      subtleDarkPalette = {};

  final ClockModel model;

  /// Predefined palettes are [vibrantLightPalette] and [subtleLightPalette] or [vibrantDarkPalette] and [subtleDarkPalette].
  final Map<ClockColor, Color> palette;

  const Clock({
    Key key,
    @required this.model,
    @required this.palette,
  })  : assert(model != null),
        assert(palette != null),
        super(key: key);

  @override
  State createState() => _ClockState();
}

class _ClockState extends State<Clock> with TickerProviderStateMixin {
  ClockModel model;

  Timer updateTimer, ballTimer;

  AnimationController analogBounceController, backgroundWaveController, ballArrivalController, ballDepartureController, bounceAwayController, bounceBackController, minuteController;

  double minuteProgress(DateTime time) => (time.second + time.millisecond / 1e3 + time.microsecond / 1e6) / 60;

  @override
  void initState() {
    super.initState();

    model = widget.model;

    final time = DateTime.now();

    analogBounceController = AnimationController(
      vsync: this,
      duration: handBounceDuration,
      // The default state has the value at 1.
      value: 1,
    );

    backgroundWaveController = AnimationController(
      vsync: this,
      duration: waveDuration,
    )..forward(from: waveProgress(time));

    ballArrivalController = AnimationController(
      vsync: this,
      duration: arrivalDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          ballDepartureController.forward(from: 0);
          ballArrivalController.reset();

          bounceBackController.reset();
          bounceAwayController.forward(from: 0);
        }
      });
    ballDepartureController = AnimationController(
      vsync: this,
      duration: departureDuration,
    );

    bounceAwayController = AnimationController(
      vsync: this,
      duration: bounceAwayDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          bounceBackController.forward(from: 0);
        }
      });
    bounceBackController = AnimationController(
      vsync: this,
      duration: bounceBackDuration,
    );

    minuteController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    )..forward(from: minuteProgress(time));

    widget.model.addListener(modelChanged);

    update(true);
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    ballTimer?.cancel();

    analogBounceController.dispose();

    backgroundWaveController.dispose();

    ballArrivalController.dispose();
    ballDepartureController.dispose();

    bounceAwayController.dispose();
    bounceBackController.dispose();

    minuteController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(Clock oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.model == widget.model) return;

    oldWidget.model.removeListener(modelChanged);
    widget.model.addListener(modelChanged);
  }

  void modelChanged() {
    setState(() {
      model = widget.model;
    });
  }

  void update([bool initial = false]) {
    final time = DateTime.now();

    updateTimer = Timer(Duration(microseconds: 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1), update);

    if (ballTimer?.isActive != true) {
      ballTimer = Timer(
        Duration(microseconds: ballEverySeconds * 1e6 ~/ 1 - (time.second % ballEverySeconds) * 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1) - arrivalDuration,
        ball,
      );
    }

    if (initial) return;

    minuteController.forward(from: minuteProgress(time));

    analogBounceController.forward(from: 0);

    () {
      // This requires the duration to be less than one minute long, but it also ensures consistent behavior.
      final progress = waveProgress(time);

      if ((backgroundWaveController.status == AnimationStatus.reverse || (time.second == 0 && backgroundWaveController.value > 1 / 2)) && !(time.second == 0 && backgroundWaveController.value < 1 / 2)) {
        backgroundWaveController.reverse(from: 1 - progress);
      } else {
        backgroundWaveController.forward(from: progress);
      }
    }();
  }

  void ball() {
    if (ballArrivalController.isAnimating || ballDepartureController.isAnimating) return;

    ballDepartureController.reset();
    ballArrivalController.forward(from: 0);
  }

  Animation<double> get analogBounceAnimation => analogBounceController;

  Animation<double> get backgroundWaveAnimation {
    return CurvedAnimation(
      parent: backgroundWaveController,
      curve: waveCurve,
      reverseCurve: waveCurve.flipped,
    );
  }

  Animation<double> get ballArrivalAnimation {
    return CurvedAnimation(
      parent: ballArrivalController,
      curve: arrivalCurve,
    );
  }

  Animation<double> get ballDepartureAnimation {
    return CurvedAnimation(
      parent: ballDepartureController,
      curve: departureCurve,
    );
  }

  Animation<double> get bounceAwayAnimation {
    return CurvedAnimation(
      parent: bounceAwayController,
      curve: bounceAwayCurve,
    );
  }

  Animation<double> get bounceBackAnimation {
    return CurvedAnimation(
      parent: bounceBackController,
      curve: bounceBackCurve,
    );
  }

  Animation<double> get minuteAnimation => minuteController;

  @override
  Widget build(BuildContext context) => CompositedClock(
        ballArrivalAnimation: ballArrivalAnimation,
        ballDepartureAnimation: ballDepartureAnimation,
        bounceAwayAnimation: bounceAwayAnimation,
        bounceBackAnimation: bounceBackAnimation,
        children: <Widget>[
          AnimatedAnalogTime(
            animation: analogBounceAnimation,
            model: model,
            palette: widget.palette,
          ),
          AnimatedDigitalTime(
            animation: minuteAnimation,
            model: model,
            palette: widget.palette,
          ),
          AnimatedTemperature(model: model, palette: widget.palette),
          AnimatedWeather(model: model, palette: widget.palette),
          Background(
            animation: backgroundWaveAnimation,
            ballColor: Color.lerp(
              widget.palette[ClockColor.ballPrimary],
              widget.palette[ClockColor.ballSecondary],
              1 / 2,
            ),
            groundColor: widget.palette[ClockColor.background],
            gooColor: widget.palette[ClockColor.goo],
            analogTimeComponentColor: widget.palette[ClockColor.analogTimeBackground],
            temperatureComponentColor: Color.lerp(
              widget.palette[ClockColor.thermometerBackgroundPrimary],
              widget.palette[ClockColor.thermometerBackgroundSecondary],
              1 / 2,
            ),
            weatherComponentColor: widget.palette[ClockColor.weatherBackground],
          ),
          Ball(
            arrivalAnimation: ballArrivalAnimation,
            departureAnimation: ballDepartureAnimation,
            primaryColor: widget.palette[ClockColor.ballPrimary],
            secondaryColor: widget.palette[ClockColor.ballSecondary],
          ),
          Location(
            text: model.location,
            textStyle: TextStyle(
              color: widget.palette[ClockColor.text],
              fontWeight: FontWeight.bold,
            ),
          ),
          Slide(
            curveColor: Color.lerp(
              widget.palette[ClockColor.ballPrimary],
              widget.palette[ClockColor.ballSecondary],
              1 / 2,
            ),
          ),
          UpdatedDate(palette: widget.palette),
        ],
      );
}
