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
  ClockModel model;

  @override
  void initState() {
    super.initState();

    model = widget.model;
  }

  @override
  void didUpdateWidget(Clock oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.model == widget.model) return;

    setState(() {
      model = widget.model;
    });
  }

  @override
  Widget build(BuildContext context) => false
      ? Text(
          '${model.weatherString}, ${model.weatherCondition}, ${model.unitString}, ${model.unit}, ${model.temperatureString}, ${model.temperature}, ${model.lowString}, ${model.low}, ${model.location}, '
          '${model.is24HourFormat}, ${model.highString}, ${model.high}')
      : CompositedClock(
          children: <Widget>[
            AnalogPart(),
          ],
        );
}
