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

class _ClockState extends State<Clock> with SingleTickerProviderStateMixin {
  ClockModel model;

  Timer timer;

  AnimationController handBounceController;

  @override
  void initState() {
    super.initState();

    model = widget.model;

    handBounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 342));

    update();
  }

  @override
  void dispose() {
    timer?.cancel();

    handBounceController.dispose();
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
    time = DateTime.now();
    handBounceController.forward(from: 0);

    timer = Timer(Duration(microseconds: 1e6 ~/ 1 - time.microsecond - time.millisecond * 1e3 ~/ 1), update);
  }

  @override
  Widget build(BuildContext context) => false
      ? Text('${model.weatherString}, ${model.weatherCondition}, ${model.unitString}, ${model.unit}, ${model.temperatureString}, ${model.temperature}, ${model.lowString}, ${model.low}, ${model.location}, '
          '${model.is24HourFormat}, ${model.highString}, ${model.high}')
      : LayoutBuilder(
          builder: (context, constraints) => CompositedClock(
            children: <Widget>[
              AnimatedBuilder(
                animation: handBounceController,
                builder: (context, _) {
                  final bounce = Curves.bounceOut.transform(handBounceController.value);
                  return AnalogPart(
                    radius: constraints.biggest.height / 3,
                    textStyle: Theme.of(context).textTheme.display1,
                    secondHandAngle: -pi / 2 +
                        // Regular distance
                        pi * 2 / 60 * time.second +
                        // Bounce
                        pi * 2 / 60 * (bounce - 1),
                    minuteHandAngle: -pi / 2 +
                        pi * 2 / 60 * time.minute +
                        // Bounce only when the minute changes.
                        (time.second != 0 ? 0 : pi * 2 / 60 * (bounce - 1)),
                    hourHandAngle:
                        // Angle equal to 0 starts on the right side and not on the top.
                        -pi / 2 +
                            // Distance for the hour.
                            pi * 2 / (model.is24HourFormat ? 24 : 12) * (model.is24HourFormat ? time.hour : time.hour % 12) +
                            // Distance for the minute.
                            pi * 2 / (model.is24HourFormat ? 24 : 12) / 60 * time.minute +
                            // Distance for the second.
                            pi * 2 / (model.is24HourFormat ? 24 : 12) / 60 / 60 * time.second,
                    hourDivisions: model.is24HourFormat ? 24 : 12,
                  );
                },
              ),
            ],
          ),
        );
}
