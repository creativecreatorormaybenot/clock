import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class Location extends LeafRenderObjectWidget {
  final String text;

  /// The [TextStyle.fontSize] of this is ignored as the text is scaled based on the available width.
  final TextStyle textStyle;

  Location({
    Key key,
    @required this.text,
    @required this.textStyle,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLocation(
      text: text,
      textStyle: textStyle,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderLocation renderObject) {
    renderObject
      ..text = text
      ..textStyle = textStyle
      // The layout depends on the text, i.e. the text to be displayed is
      // only updated when laying out, which is why this is not markNeedsPaint.
      ..markNeedsLayout();
  }
}

class RenderLocation extends RenderCompositionChild {
  RenderLocation({
    this.text,
    this.textStyle,
  }) : super(ClockComponent.location);

  String text;
  TextStyle textStyle;

  TextPainter textPainter;

  @override
  void performLayout() {
    final width = constraints.biggest.width;

    textPainter = TextPainter(
        text: TextSpan(
            text: text, style: textStyle.copyWith(fontSize: width / 14)),
        textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: width);

    size = Size(width, textPainter.height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    textPainter.paint(canvas, Offset.zero);

    canvas.restore();
  }
}
