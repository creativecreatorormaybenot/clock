import 'package:canvas_clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';

/// Clock customizer that uses the provided [ClockCustomizer].
///
/// The only function of this widget is taking a [ClockModelBuilder]
/// instead of a [ClockBuilder].
///
/// I left the [ClockCustomizer] basically unchanged, but removed
/// two [SafeArea] widgets as they destroy the full screen experience.
class ManualCustomizer extends StatelessWidget {
  final ClockModelBuilder builder;

  const ManualCustomizer({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClockCustomizer(
      (model) => Builder(
        builder: (context) => builder(context, model),
      ),
    );
  }
}
