import 'package:canvas_clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

const start = CustomizationData(
  unit: TemperatureUnit.celsius,
  location: "creativecreatorormaybenot's place",
  temperature: 21.5,
  high: 42,
  low: -5,
  condition: WeatherCondition.snowy,
  theme: ThemeMode.dark,
  timeFormat: TimeFormat.standard,
);

class AutomatedCustomizer extends StatefulWidget {
  final ClockModelBuilder builder;

  const AutomatedCustomizer({
    Key key,
    @required this.builder,
  })
      : assert(builder != null),
        super(key: key);

  @override
  State createState() => _AutomatedCustomizerState();
}

class _AutomatedCustomizerState extends State<AutomatedCustomizer> {
  ClockModel model;

  ThemeMode _theme;

  ThemeMode get theme => _theme;

  set theme(ThemeMode value) {
    if (value == _theme) return;

    _theme = value;
    update();
  }

  @override
  void initState() {
    super.initState();

    model = ClockModel();
    model.addListener(update);
  }

  @override
  void dispose() {
    model.dispose();

    super.dispose();
  }

  void update() {
    setState(() {});
  }

  void applyData(CustomizationData data) {
    theme = data.theme;

    model..location = data.location
    ..is24HourFormat = data.timeFormat == TimeFormat.standard
    ..temperature = data.temperature
    ..high = data.high
    ..low = data.low
    ;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: theme,
      home: Builder(
        builder: (context) =>
            Container(
              color: Theme
                  .of(context)
                  .canvasColor,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 5 / 3,
                  child: widget.builder(context, model),
                ),
              ),
            ),
      ),
    );
  }
}

class CustomizationData {
  final ThemeMode theme;

  final String location;

  final TemperatureUnit unit;

  final double temperature, high, low;

  final WeatherCondition condition;

  final TimeFormat timeFormat;

  const CustomizationData({
    @required this.theme,
    @required this.location,
    @required this.unit,
    @required this.temperature,
    @required this.high,
    @required this.low,
    @required this.condition,
    @required this.timeFormat,
  })
      : assert(theme != null),
        assert(location != null),
        assert(unit != null),
        assert(temperature != null),
        assert(high != null),
        assert(low != null),
        assert(condition != null),
        assert(timeFormat != null);

  CustomizationData copyWith(CustomizationData other) {
    return CustomizationData(
        theme: other.theme ?? theme,
        location: other.location ?? location,

    );
  }
}

enum TimeFormat {
  amPm,

  /// Indicates the 24 hour time format.
  ///
  /// This name is obviously controversial,
  /// but I could not think of a better name
  /// because variables cannot start with digits.
  standard,
}
