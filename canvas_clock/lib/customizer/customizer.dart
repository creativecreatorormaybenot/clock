import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';

export 'automatic.dart';
export 'manual.dart';

typedef ClockModelBuilder = Widget Function(BuildContext context, ClockModel model);

class Customizer extends StatefulWidget {
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
  _CustomizerState createState() => _CustomizerState();
}

class _CustomizerState extends State<Customizer> {
  @override
  Widget build(BuildContext context) {
    if (widget.automatic) return Container();

    return ClockCustomizer((model) => widget.builder(context, model));
  }
}
