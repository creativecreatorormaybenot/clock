import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class Slide extends LeafRenderObjectWidget {
  final Color curveColor;

  Slide({
    Key key,
    @required this.curveColor,
  })  : assert(curveColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSlide(
      curveColor: curveColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSlide renderObject) {
    renderObject..curveColor = curveColor;
  }
}

class SlideParentData extends ClockChildrenParentData {
  Offset start, end, destination;

  double ballRadius;
}

class RenderSlide extends RenderCompositionChild<ClockComponent, SlideParentData> {
  RenderSlide({
    Color curveColor,
  })  : _curveColor = curveColor,
        super(ClockComponent.slide);

  Color _curveColor;

  set curveColor(Color value) {
    assert(value != null);

    if (_curveColor == value) {
      return;
    }

    _curveColor = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData.hasSemanticsInformation = false;
  }

  @override
  void performResize() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // By translating to the given offset,
    // the offset needs to be subtracted from the given
    // points because they are relative to the parent,
    // i.e. relative to the canvas position of the parent.
    final start = compositionData.start - offset, end = compositionData.end - offset, destination = compositionData.destination - offset;

    // Need to know where the start line is located in order to
    // properly add padding to account for the ball's size.
    final startLeft = start.dx < end.dx;

    final startLine = Line2d(start: start, end: destination)
            .endPadding(.7)
            // The start line should touch the ball on its side.
            // The same also goes for the end line, which is
            // why startLeft is required.
            .shift(Offset(compositionData.ballRadius * (startLeft ? -1 : 1), 0)),
        endLine = Line2d(start: end, end: destination).endPadding(.7).shift(Offset(compositionData.ballRadius * (startLeft ? 1 : -1), 0));

    var travelLine = Line2d(start: end, end: start);

    travelLine = travelLine
        // Pad by the ball radius on both sides.
        .padding(compositionData.ballRadius / travelLine.length)
        // The line should touch the ball's bottom.
        .shift(Offset(0, compositionData.ballRadius));

    final paint = Paint()..color = _curveColor, strokeWidth = size.shortestSide / 51;

    canvas.drawPath(travelLine.pathWithWidth(strokeWidth), paint);
    canvas.drawPath(startLine.pathWithWidth(strokeWidth), paint);
    canvas.drawPath(endLine.pathWithWidth(strokeWidth), paint);

    canvas.restore();
  }
}
