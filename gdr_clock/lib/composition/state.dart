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

  AnimationController analogBounceController, backgroundWaveController, ballArrivalController, ballDepartureController;

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
        }
      });
    ballDepartureController = AnimationController(
      vsync: this,
      duration: departureDuration,
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
    final time = DateTime.now(), nextSecond = Duration(microseconds: 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1);

    updateTimer = Timer(nextSecond, update);

    if (ballTimer?.isActive != true) ballTimer = Timer(nextSecond - arrivalDuration, ball);

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
    ballDepartureController.reset();
    ballArrivalController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => CompositedClock(
        ballArrivalAnimation: ballArrivalController,
        ballDepartureAnimation: ballDepartureController,
        children: <Widget>[
          AnimatedAnalogTime(animation: analogBounceController, model: model),
          AnimatedTemperature(model: model),
          AnimatedWeather(model: model),
          Background(
            animation: CurvedAnimation(
              parent: backgroundWaveController,
              curve: waveCurve,
              reverseCurve: waveCurve.flipped,
            ),
          ),
          const Ball(),
          Location(
            text: model.location,
            textStyle: const TextStyle(color: Color(0xff000000), fontWeight: FontWeight.bold),
          ),
          const UpdatedDate(),
        ],
      );
}
