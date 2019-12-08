import 'package:flutter/widgets.dart';
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
  @override
  Widget build(BuildContext context) => true ? Container() : CompositedClock();
}
