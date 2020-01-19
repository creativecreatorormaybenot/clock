import 'package:canvas_clock/clock.dart';
import 'package:canvas_clock/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

export 'automatic.dart';
export 'manual.dart';

typedef ClockModelBuilder = Widget Function(BuildContext context, ClockModel model);

/// Customization flows control the behavior of the clock.
///
/// The selected mode is determined by the [customizationFlowMode]
/// constants.
enum CustomizationFlow {
  manual,
  automatic,
}

class Customizer extends StatelessWidget {
  final ClockModelBuilder builder;

  final CustomizationFlow mode;

  const Customizer({
    Key key,
    @required this.mode,
    @required this.builder,
  })  : assert(mode != null),
        assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mode == CustomizationFlow.automatic) {
      return AutomatedCustomizer(builder: builder);
    }

    return ManualCustomizer(builder: builder);
  }
}
