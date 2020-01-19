import 'package:canvas_clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

export 'automatic.dart';
export 'manual.dart';

typedef ClockModelBuilder = Widget Function(
    BuildContext context, ClockModel model);

class Customizer extends StatelessWidget {
  final ClockModelBuilder builder;

  final bool automatic;

  const Customizer({
    Key key,
    @required this.automatic,
    @required this.builder,
  })  : assert(automatic != null),
        assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (automatic) {
      return AutomatedCustomizer(builder: builder);
    }

    return ManualCustomizer(builder: builder);
  }
}
