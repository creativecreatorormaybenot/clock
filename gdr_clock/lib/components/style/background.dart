import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

const waveDuration = Duration(minutes: 1), waveCurve = Curves.easeInOut;

double waveProgress(DateTime time) => 1 / waveDuration.inSeconds * time.second;

class Background extends LeafRenderObjectWidget {
  final Animation<double> animation;

  const Background({
    Key key,
    @required this.animation,
  })  : assert(animation != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBackground(
      animation: animation,
    );
  }
}

class RenderBackground extends RenderCompositionChild {
  final Animation<double> animation;

  RenderBackground({
    this.animation,
  }) : super(ClockComponent.background);

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    animation.removeListener(markNeedsPaint);

    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // Do not need to clip here because CompositedClock already clips the canvas.

    final clockData = parentData as ClockChildrenParentData;

    final gooArea = Rect.fromLTWH(
      // Infinite width and height ensure that the indentations of the goo caused by components will always consider the complete object, even if some of it is out of view.
      // Using maxFinite because negativeInfinity for the left value throws NaN errors.
      -double.maxFinite,
      size.height / 2 + (animation.value - 1 / 2) * size.height / 5,
      double.infinity,
      double.maxFinite,
    );
    final componentsInGoo = [
      clockData.rectOf(ClockComponent.analogTime),
      clockData.rectOf(ClockComponent.weather),
      clockData.rectOf(ClockComponent.temperature),
    ].where((rect) => rect.overlaps(gooArea)).map((rect) => gooArea.intersect(rect)).toList();

    final canvas = context.canvas;

    canvas.save();
    // Translate to upper left corner of the clock's area.
    canvas.translate(offset.dx, offset.dy);

    // This path is supposed to represent the goo being indented by the components, which is achieved by adding Bézier curves.
    final cut = Path()..moveTo(0, gooArea.top);

    componentsInGoo.sort((a, b) => a.left.compareTo(b.left));

    // Interpolation between paths is not currently possible (see https://github.com/flutter/flutter/issues/12043),
    // hence, my solution is simply merging the rects if they overlap, which does not produce a visually pleasing
    // effect, especially because of the harsh transition, but it is better than having points on the curve that
    // do not work together, causing some parts to wrap back and forth.
    final rects = [];
    Rect previous;
    for (var i = 0; i <= componentsInGoo.length; i++) {
      if (i == componentsInGoo.length) {
        rects.add(previous);
        break;
      }

      final rect = componentsInGoo[i];

      if (previous == null) {
        previous = rect;
        continue;
      }

      if (previous.overlaps(rect)) {
        previous = previous.expandToInclude(rect);
        continue;
      }

      rects.add(previous);
      previous = rect;
    }

    for (var i = 0; i < rects.length; i++) {
      final rect = rects[i];

      cut
        ..cubicTo(
          rect.centerLeft.dx,
          rect.centerLeft.dy,
          rect.bottomLeft.dx,
          rect.bottomLeft.dy,
          rect.bottomCenter.dx,
          rect.bottomCenter.dy,
        )
        ..cubicTo(
          rect.bottomRight.dx,
          rect.bottomRight.dy,
          rect.centerRight.dx,
          rect.centerRight.dy,
          i == rects.length - 1 ? size.width : (rect.right + rects[i + 1].left) / 2,
          i == rects.length - 1 ? gooArea.top : (rect.center.dy + rects[i + 1].center.dy) / 2,
        );
    }

    cut.lineTo(size.width, gooArea.top);

    final upperPath = Path()
      ..extendWithPath(cut, Offset.zero)
      // Line to top right, then top left, and then back to start to fill whole upper area.
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(
        upperPath,
        Paint()
          ..color = const Color(0xffffe312)
          ..style = PaintingStyle.fill);

    final lowerPath = Path()
      ..extendWithPath(cut, Offset.zero)
      // Line to bottom right, then bottom left, and then back to start to fill whole lower area.
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        lowerPath,
        Paint()
          ..color = const Color(0xffff4683)
          ..style = PaintingStyle.fill);

    canvas.restore();
  }
}
