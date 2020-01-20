import 'dart:async';

import 'package:canvas_clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

const nextDataEvery = Duration(microseconds: 120 / 7 * 1e6 ~/ 1),
// These need to be applied in sequence in order to make sense.
    data = [
  // Initial data
  CustomizationData(
    unit: TemperatureUnit.celsius,
    location: "creativemaybeno's place",
    temperature: 24.5,
    high: 29,
    low: 17,
    condition: WeatherCondition.sunny,
    theme: ThemeMode.light,
    timeFormat: TimeFormat.standard,
  ),
  // Mountain view (as of writing)
  CustomizationData(
    location: 'Mountain View, CA',
    unit: TemperatureUnit.fahrenheit,
    temperature: 47,
    low: 46,
    high: 58,
    condition: WeatherCondition.cloudy,
    timeFormat: TimeFormat.amPm,
  ),
  // Antarctica right now
  CustomizationData(
    location: 'Casey, Antarctica',
    theme: ThemeMode.dark,
    high: 1,
    temperature: 0,
    low: -3,
    unit: TemperatureUnit.celsius,
    condition: WeatherCondition.snowy,
    timeFormat: TimeFormat.standard,
  ),
  CustomizationData(
    location: 'Pasighat, India',
    condition: WeatherCondition.thunderstorm,
    temperature: 13,
    low: 13,
    high: 19,
  ),
  CustomizationData(
    location: 'Cork, Ireland',
    temperature: 5,
    high: 8,
    low: 2,
    condition: WeatherCondition.foggy,
  ),
  CustomizationData(
    location: 'Olympia, WA',
    unit: TemperatureUnit.fahrenheit,
    temperature: 44,
    high: 50,
    low: 42,
    theme: ThemeMode.light,
    timeFormat: TimeFormat.amPm,
    condition: WeatherCondition.rainy,
  ),
  CustomizationData(
    location: 'Coral Bay, WA',
    condition: WeatherCondition.windy,
    unit: TemperatureUnit.celsius,
    temperature: 25,
    high: 34,
    low: 22,
  ),
];

class AutomatedCustomizer extends StatefulWidget {
  final ClockModelBuilder builder;

  const AutomatedCustomizer({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  State createState() => _AutomatedCustomizerState();
}

class _AutomatedCustomizerState extends State<AutomatedCustomizer> {
  ClockModel model;

  ThemeMode _theme;

  Timer timer;

  @override
  void initState() {
    super.initState();

    model = ClockModel();
    model.addListener(update);

    timer = Timer.periodic(nextDataEvery, (_) => changeData());
    changeData();
  }

  @override
  void dispose() {
    model.dispose();

    timer.cancel();

    super.dispose();
  }

  ThemeMode get theme => _theme;

  set theme(ThemeMode value) {
    if (value == _theme) return;

    setState(() {
      _theme = value;
    });
  }

  void update() {
    setState(() {});
  }

  int currentIndex;

  void changeData() {
    if (currentIndex == null) {
      setState(() {
        applyData(data[currentIndex = 0]);
      });

      return;
    }

    final previousData = data[currentIndex];

    currentIndex++;

    if (currentIndex >= data.length) {
      currentIndex = 0;
    }

    setState(() {
      applyData(previousData.copyWith(data[currentIndex]));
    });
  }

  void applyData(CustomizationData data) {
    theme = data.theme;

    model
      ..location = data.location
      ..is24HourFormat = data.timeFormat == TimeFormat.standard
      ..temperature = data.temperature
      ..high = data.high
      ..low = data.low
      ..weatherCondition = data.condition
      ..unit = data.unit;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: theme,
      home: Builder(
        builder: (context) {
          return Container(
            color: Theme.of(context).canvasColor,
            child: Center(
              child: AspectRatio(
                aspectRatio: 5 / 3,
                child: widget.builder(context, model),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomizationData {
  final WeatherCondition condition;

  final double high, low, temperature;

  final String location;

  final ThemeMode theme;

  final TimeFormat timeFormat;

  final TemperatureUnit unit;

  const CustomizationData({
    this.condition,
    this.high,
    this.location,
    this.low,
    this.temperature,
    this.theme,
    this.timeFormat,
    this.unit,
  });

  CustomizationData copyWith(CustomizationData other) {
    return CustomizationData(
      condition: other.condition ?? condition,
      high: other.high ?? high,
      location: other.location ?? location,
      low: other.low ?? low,
      temperature: other.temperature ?? temperature,
      theme: other.theme ?? theme,
      timeFormat: other.timeFormat ?? timeFormat,
      unit: other.unit ?? unit,
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
