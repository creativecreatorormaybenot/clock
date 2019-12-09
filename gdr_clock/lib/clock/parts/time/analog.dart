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

class RenderAnalogPart extends RenderBox {
  CompositedClockChildrenParentData get compositedClockData =>
      parentData as CompositedClockChildrenParentData;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositedClockData.valid = true;
    compositedClockData.component = CompositedClockComponent.analogTime;
  }

  @override
  void detach() {
    super.detach();
  }
}
