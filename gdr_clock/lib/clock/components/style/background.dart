import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class BackgroundComponent extends LeafRenderObjectWidget {
  BackgroundComponent({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBackgroundComponent();
  }
}

class RenderBackgroundComponent extends RenderClockComponent {
  RenderBackgroundComponent() : super(ClockComponent.background);
}
