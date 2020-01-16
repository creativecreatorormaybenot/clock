import 'package:canvas_clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

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

  @override
  void initState() {
    super.initState();

    model = ClockModel();
    model.addListener(update);
  }

  @override
  void dispose() {
    model.dispose();

    super.dispose();
  }

  void update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 5 / 3,
        child: widget.builder(context, model),
      ),
    );
  }
}
