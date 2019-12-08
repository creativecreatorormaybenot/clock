import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CompositedClock extends MultiChildRenderObjectWidget {
  CompositedClock({
    Key key,
  }) : super(key: key, children: []);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCompositedClock();
  }
}

class CompositedClockChildrenParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCompositedClock extends RenderBox with ContainerRenderObjectMixin<RenderBox, CompositedClockChildrenParentData>, RenderBoxContainerDefaultsMixin<RenderBox, CompositedClockChildrenParentData> {}
