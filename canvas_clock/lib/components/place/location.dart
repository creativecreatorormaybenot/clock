import 'package:canvas_clock/clock.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Location extends LeafRenderObjectWidget {
  final String text;

  /// The [TextStyle.fontSize] of this is ignored as the text is scaled based on the available width.
  final TextStyle textStyle;

  final Color shadowColor;

  Location({
    Key key,
    @required this.text,
    @required this.textStyle,
    @required this.shadowColor,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLocation(
      text: text,
      textStyle: textStyle,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderLocation renderObject) {
    renderObject
      ..text = text
      ..textStyle = textStyle
      ..shadowColor = shadowColor;
  }
}

class RenderLocation extends RenderCompositionChild<ClockComponent, ClockChildrenParentData> {
  RenderLocation({
    String text,
    TextStyle textStyle,
    Color shadowColor,
  })  : _text = text,
        _textStyle = textStyle,
        _shadowColor = shadowColor,
        super(ClockComponent.location);

  String _text;

  set text(String value) {
    assert(value != null);

    if (_text == value) {
      return;
    }

    _text = value;
    // The layout depends on the text, i.e. the text to be displayed is
    // only updated when laying out, which is why this is not markNeedsPaint.
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  TextStyle _textStyle;

  set textStyle(TextStyle value) {
    assert(value != null);

    if (_textStyle == value) {
      return;
    }

    _textStyle = value;
    markNeedsLayout();
  }

  Color _shadowColor;

  set shadowColor(Color value) {
    assert(value != null);

    if (_shadowColor == value) {
      return;
    }

    _shadowColor = value;
    // This is not optimal, I know,
    // but it is w/e now.
    markNeedsLayout();
  }

  TextPainter _textPainter;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData.hasSemanticsInformation = true;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    config
      ..isReadOnly = true
      ..textDirection = TextDirection.ltr
      ..label = 'Location is $_text';
  }

  @override
  void performLayout() {
    final width = constraints.biggest.width;

    _textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: _textStyle.copyWith(
          fontSize: width / 12.3,
          shadows: [
            Shadow(
              color: _shadowColor,
              blurRadius: width / 19,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout(maxWidth: width);

    size = _textPainter.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _textPainter.paint(canvas, Offset.zero);

    canvas.restore();
  }
}
