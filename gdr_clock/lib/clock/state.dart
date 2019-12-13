import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock/clock.dart';

class Clock extends StatefulWidget {
  final ClockModel model;

  const Clock({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  State createState() => _ClockState();
}

class _ClockState extends State<Clock> with TickerProviderStateMixin {
  ClockModel model;

  Timer timer;

  AnimationController analogBounceController, layoutMover;

  @override
  void initState() {
    super.initState();

    model = widget.model;

    analogBounceController = AnimationController(vsync: this, duration: handBounceDuration);
    layoutMover = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    update();
  }

  @override
  void dispose() {
    timer?.cancel();

    analogBounceController.dispose();
    layoutMover.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Clock oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.model == widget.model) return;

    setState(() {
      model = widget.model;
    });
  }

  void update() {
    analogBounceController.forward(from: 0);

    final time = DateTime.now();
    timer = Timer(Duration(microseconds: 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1), update);

    if (time.second == 0) {
      if (layoutMover.value == 0) {
        layoutMover.forward();
      } else if (layoutMover.value == 1) layoutMover.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => false
      ? Text('${model.weatherString}, ${model.weatherCondition}, ${model.unitString}, ${model.unit}, ${model.temperatureString}, ${model.temperature}, ${model.lowString}, ${model.low}, ${model.location}, '
          '${model.is24HourFormat}, ${model.highString}, ${model.high}')
      : CompositedClock(
          layoutMover: layoutMover,
          children: <Widget>[
            BackgroundComponent(),
            AnimatedAnalogComponent(animation: analogBounceController, model: model),
          ],
        );
}
