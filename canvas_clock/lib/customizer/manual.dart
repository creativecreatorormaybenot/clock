import 'package:canvas_clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';

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
