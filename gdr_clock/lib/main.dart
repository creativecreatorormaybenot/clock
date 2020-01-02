import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:gdr_clock/clock.dart';

void main() {
  timeDilation = 20;
  runApp(ClockCustomizer((model) => Clock(model: model)));
}
