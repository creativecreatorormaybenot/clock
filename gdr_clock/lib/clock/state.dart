import 'dart:async';
import 'dart:math';

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

class _ClockState extends State<Clock> {
  ClockModel model;

  Timer timer;

  @override
  void initState() {
    super.initState();

    model = widget.model;

    update();
  }

  @override
  void dispose() {
    timer?.cancel();
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

  DateTime time;

  void update() {
    setState(() {
      time = DateTime.now();

      timer =
          Timer(Duration(microseconds: 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1), update);
    });
  }

  @override
  Widget build(BuildContext context) => false
      ? Text(
          '${model.weatherString}, ${model.weatherCondition}, ${model.unitString}, ${model.unit}, ${model.temperatureString}, ${model.temperature}, ${model.lowString}, ${model.low}, ${model.location}, '
          '${model.is24HourFormat}, ${model.highString}, ${model.high}')
      : LayoutBuilder(
          builder: (context, constraints) => CompositedClock(
            children: <Widget>[
              AnalogPart(
                radius: constraints.biggest.height / 3,
                textStyle: Theme.of(context).textTheme.display1,
                handAngle: pi * 2 / 60 * time.second,
                hourDivisions: model.is24HourFormat ? 24 : 12,
              ),
            ],
          ),
        );
}
