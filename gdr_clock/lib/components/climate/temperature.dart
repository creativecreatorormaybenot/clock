import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class Temperature extends LeafRenderObjectWidget {
  Temperature({Key key}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTemperature();
  }
}

class RenderTemperature extends RenderCompositionChild {
  RenderTemperature() : super(ClockComponent.temperature);


}
