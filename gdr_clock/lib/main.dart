import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:gdr_clock/clock/clock.dart';

void main() {
  runApp(ClockCustomizer((model) => Clock(model: model)));
}
