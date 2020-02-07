import 'package:canvas_clock/clock.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Location extends LeafRenderObjectWidget {
  final String text;

  /// The [TextStyle.fontSize] of this is ignored as the text is scaled based on the available width.
  final TextStyle textStyle;

  final Color shadowColor, dropCapColor;

  Location({
    Key key,
    @required this.text,
    @required this.textStyle,
    @required this.shadowColor,
    @required this.dropCapColor,
  })  : assert(text != null),
        assert(textStyle != null),
        assert(shadowColor != null),
        assert(dropCapColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLocation(
      text: text,
      textStyle: textStyle,
      shadowColor: shadowColor,
      dropCapColor: dropCapColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderLocation renderObject) {
    renderObject
      ..text = text
      ..textStyle = textStyle
      ..shadowColor = shadowColor
      ..dropCapColor = dropCapColor;
  }
}

class RenderLocation
    extends RenderCompositionChild<ClockComponent, ClockChildrenParentData> {
  RenderLocation({
    String text,
    TextStyle textStyle,
    Color shadowColor,
    Color dropCapColor,
  })  : _text = text,
        _textStyle = textStyle,
        _shadowColor = shadowColor,
        _dropCapColor = dropCapColor,
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

  Color _shadowColor, _dropCapColor;

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

  set dropCapColor(Color value) {
    assert(value != null);

    if (_dropCapColor == value) {
      return;
    }

    _dropCapColor = value;
    markNeedsPaint();
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
        children: [
          TextSpan(
            text: _text.substring(0, 1),
            style: TextStyle(
              fontSize: width / 8,
              color: _dropCapColor,
            ),
          ),
          TextSpan(text: _text.substring(1)),
        ],
        style: _textStyle.copyWith(
          fontSize: width / 9.7,
          shadows: [
            Shadow(
              color: _shadowColor.withOpacity(.46),
              // I wanted to use a bigger blur radius,
              // but it looks boxy in Flutter web, i.e.
              // the shadow is clipped there.
              blurRadius: width / 112,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout(maxWidth: width);

    // I used _textPainter.size here before,
    // however, on Flutter web, the width of the
    // text painter sometimes exceeded the maxWidth
    // specified (:
    // https://github.com/flutter/flutter/issues/49183
    size = Size(width, _textPainter.height);
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
