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

  AnimationController analogBounceController, layoutController;

  @override
  void initState() {
    super.initState();

    model = widget.model;

    analogBounceController = AnimationController(vsync: this, duration: handBounceDuration);
    layoutController = AnimationController(vsync: this, duration: layoutAnimationDuration);

    widget.model.addListener(modelChanged);

    update();
  }

  @override
  void dispose() {
    timer?.cancel();

    analogBounceController.dispose();
    layoutController.dispose();
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
    // Change layout when the model changes.
    if (layoutController.value == 0) {
      layoutController.forward();
    } else if (layoutController.value == 1) layoutController.reverse();

    setState(() {
      model = widget.model;
    });
  }

  void update() {
    analogBounceController.forward(from: 0);

    final time = DateTime.now();
    timer = Timer(Duration(microseconds: 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1), update);

//    // Change layout when the minute changes.
//    if (time.second == 0) {
//      if (layoutController.value == 0) {
//        layoutController.forward();
//      } else if (layoutController.value == 1) layoutController.reverse();
//    }
  }

  @override
  Widget build(BuildContext context) => false
      ? Text('${model.weatherString}, ${model.weatherCondition}, ${model.unitString}, ${model.unit}, ${model.temperatureString}, ${model.temperature}, ${model.lowString}, ${model.low}, ${model.location}, '
          '${model.is24HourFormat}, ${model.highString}, ${model.high}')
      : CompositedClock(
          layoutAnimation: layoutController,
          children: <Widget>[
            BackgroundComponent(),
            AnimatedAnalogComponent(layoutAnimation: layoutController, animation: analogBounceController, model: model),
          ],
        );
}
