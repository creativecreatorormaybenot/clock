import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:gdr_clock/clock.dart';

const useVibrantPalette = true;

void main() {
  runApp(
    ClockCustomizer(
      (model) => Builder(
        builder: (context) {
          return Clock(
            model: model,
            palette: resolvePalette(context),
          );
        },
      ),
    ),
  );
}
