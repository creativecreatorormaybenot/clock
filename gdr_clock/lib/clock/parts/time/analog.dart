import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock/clock.dart';

class AnalogPart extends LeafRenderObjectWidget {
  const AnalogPart();

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnalogPart();
  }
}

class RenderAnalogPart extends RenderClockPart {
  RenderAnalogPart() : super(ClockComponent.analogTime);

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
  }
}
