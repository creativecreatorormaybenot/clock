import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:gdr_clock/clock/clock.dart';

void main() {
  timeDilation = 11.42; // todo remove
  runApp(ClockCustomizer((model) => Clock(model: model)));
}
