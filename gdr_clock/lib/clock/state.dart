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

class _ClockState extends State<Clock> with SingleTickerProviderStateMixin {
  ClockModel model;

  Timer timer;

  AnimationController analogBounceController;

  @override
  void initState() {
    super.initState();

    model = widget.model;

    analogBounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 342));

    update();
  }

  @override
  void dispose() {
    timer?.cancel();

    analogBounceController.dispose();
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
  }

  @override
  Widget build(BuildContext context) => false
      ? Text('${model.weatherString}, ${model.weatherCondition}, ${model.unitString}, ${model.unit}, ${model.temperatureString}, ${model.temperature}, ${model.lowString}, ${model.low}, ${model.location}, '
          '${model.is24HourFormat}, ${model.highString}, ${model.high}')
      : CompositedClock(
          children: <Widget>[
            AnimatedAnalogPart(animation: analogBounceController, model: model),
          ],
        );
}
