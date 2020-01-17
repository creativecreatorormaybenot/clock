import 'dart:async';
import 'dart:math';

import 'package:canvas_clock/clock.dart';
import 'package:canvas_clock/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

const spinUpDuration = Duration(milliseconds: 1435);

class Clock extends StatefulWidget {
  final ClockModel model;

  /// Defines the clock's color palette.
  ///
  /// See [Palette].
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

  Timer updateTimer;

  AnimationController analogBounceController, backgroundWaveController, ballTravelController, ballArrivalController, ballDepartureController, bounceController, minuteController, spinUpController;

  BallTrips ballTrips;

  double minuteProgress(DateTime time) => (time.second + time.millisecond / 1e3 + time.microsecond / 1e6) / 60;

  @override
  void initState() {
    super.initState();

    model = widget.model;

    final time = DateTime.now();

    spinUpController = AnimationController(
      vsync: this,
      duration: spinUpDuration,
    )..forward(from: 0);

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

    ballTrips = BallTrips();
    ballTravelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: ballEvery) - departureDuration - arrivalDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          ballTravelController.reset();

          ballArrivalController.forward(from: 0);
        }
      });
    ballArrivalController = AnimationController(
      vsync: this,
      duration: arrivalDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          ballArrivalController.reset();

          ballDepartureController.forward(from: 0);
          Palette.of(context).vibrant = !Palette.of(context).vibrant;

          // Starting the animation for the bouncing
          // of the element hit.
          bounceController.forward(from: 0);
        }
      });
    ballDepartureController = AnimationController(
      vsync: this,
      duration: departureDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          ballDepartureController.reset();
          ballTrips.count++;

          ballTravelController.forward(from: ballTravelProgress(DateTime.now()));
        }
      });

    bounceController = AnimationController(
      vsync: this,
      duration: bounceAwayDuration + bounceBackDuration,
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

    analogBounceController.dispose();

    backgroundWaveController.dispose();

    ballTravelController.dispose();
    ballArrivalController.dispose();
    ballDepartureController.dispose();

    bounceController.dispose();

    minuteController.dispose();

    spinUpController.dispose();

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

  double ballTravelProgress(DateTime time) {
    // toGo is the time until the next ball
    // arrival animation should start in microseconds.
    final toGo = ballEvery * 1e6 ~/ 1 - (time.second % ballEvery) * 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1 - arrivalDuration.inMicroseconds;

    return max(0, 1 - toGo / ballTravelController.duration.inMicroseconds);
  }

  void update([bool initial = false]) {
    final time = DateTime.now();

    updateTimer = Timer(Duration(microseconds: 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1), update);

    if (!ballArrivalController.isAnimating && !ballDepartureController.isAnimating) {
      // It should be fine to call this even when the travel
      // controller is already animating because it should be
      // at that exact value at the moment. The real value
      // will be close enough to the theoretical one.
      ballTravelController.forward(from: ballTravelProgress(time));
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

  Animation<double> get analogBounceAnimation => analogBounceController;

  Animation<double> get backgroundWaveAnimation {
    return CurvedAnimation(
      parent: backgroundWaveController,
      curve: waveCurve,
      reverseCurve: waveCurve.flipped,
    );
  }

  Animation<double> get ballTravelAnimation {
    return CurvedAnimation(
      parent: ballTravelController,
      curve: travelCurve,
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

  Animation<double> get bounceAnimation {
    return TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: bounceAwayCurve)),
        weight: bounceAwayDuration.inMicroseconds / bounceController.duration.inMicroseconds,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: bounceBackCurve)),
        weight: bounceBackDuration.inMicroseconds / bounceController.duration.inMicroseconds,
      ),
    ]).animate(bounceController);
  }

  Animation<double> get minuteAnimation => minuteController;

  Animation<double> get spinUpAnimation {
    return CurvedAnimation(
      parent: spinUpController,
      // When the clock face flips up to reveal itself,
      // I imagine it to be like a movie logo reveal:
      // a bit of THX, slowing easing in to finally
      // smash to stop.
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedClock(
      spinUpAnimation: spinUpAnimation,
      children: <Widget>[
        AnimatedAnalogTime(
          animation: analogBounceAnimation,
          bounceAnimation: bounceAnimation,
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
          analogTimeBounceAnimation: bounceAnimation,
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
          travelAnimation: ballTravelAnimation,
          arrivalAnimation: ballArrivalAnimation,
          departureAnimation: ballDepartureAnimation,
          trips: ballTrips,
          primaryColor: widget.palette[ClockColor.ballPrimary],
          secondaryColor: widget.palette[ClockColor.ballSecondary],
          dotsIdleColor: widget.palette[ClockColor.dotsIdleColor],
          dotsPrimedColor: widget.palette[ClockColor.dotsPrimedColor],
          dotsDisengagedColor: widget.palette[ClockColor.dotsDisengagedColor],
          shadowColor: widget.palette[ClockColor.shadow],
        ),
        Location(
          text: model.location,
          textStyle: TextStyle(
            color: widget.palette[ClockColor.text],
            fontWeight: FontWeight.bold,
          ),
        ),
        Slide(
          ballTravelAnimation: ballTravelAnimation,
          ballArrivalAnimation: ballArrivalAnimation,
          ballDepartureAnimation: ballDepartureAnimation,
          primaryColor: widget.palette[ClockColor.slidePrimary],
          secondaryColor: widget.palette[ClockColor.slideSecondary],
          shadowColor: widget.palette[ClockColor.shadow],
        ),
        UpdatedDate(palette: widget.palette),
      ],
    );
  }
}
