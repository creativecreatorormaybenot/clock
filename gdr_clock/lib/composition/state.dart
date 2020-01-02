import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';

class Clock extends StatefulWidget {
  final ClockModel model;

  const Clock({
    Key key,
    @required this.model,
  })  : assert(model != null),
        super(key: key);

  @override
  State createState() => _ClockState();
}

class _ClockState extends State<Clock> with TickerProviderStateMixin {
  ClockModel model;

  Timer updateTimer, ballTimer;

  AnimationController analogBounceController, backgroundWaveController, ballArrivalController, ballDepartureController, bounceAwayController, bounceBackController;

  @override
  void initState() {
    super.initState();

    model = widget.model;

    analogBounceController = AnimationController(
      vsync: this,
      duration: handBounceDuration,
      // The default state has the value at 1.
      value: 1,
    );

    backgroundWaveController = AnimationController(
      vsync: this,
      duration: waveDuration,
    )..forward(from: waveProgress(DateTime.now()));

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
        Duration(microseconds: 5e6 ~/ 1 - (time.second % 5) * 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1) - arrivalDuration,
        ball,
      );
    }

    if (initial) return;

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

  @override
  Widget build(BuildContext context) => CompositedClock(
        ballArrivalAnimation: ballArrivalAnimation,
        ballDepartureAnimation: ballDepartureAnimation,
        bounceAwayAnimation: bounceAwayAnimation,
        bounceBackAnimation: bounceBackAnimation,
        children: <Widget>[
          AnimatedAnalogTime(animation: analogBounceAnimation, model: model),
          AnimatedTemperature(model: model),
          AnimatedWeather(model: model),
          Background(animation: backgroundWaveAnimation),
          Ball(
            arrivalAnimation: ballArrivalAnimation,
            departureAnimation: ballDepartureAnimation,
          ),
          Location(
            text: model.location,
            textStyle: const TextStyle(color: Color(0xff000000), fontWeight: FontWeight.bold),
          ),
          const UpdatedDate(),
        ],
      );
}
