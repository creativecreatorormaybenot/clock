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
      ..textStyle = textStyle;
  }
}

class RenderLocation extends RenderCompositionChild<ClockComponent, ClockChildrenParentData> {
  RenderLocation({
    String text,
    TextStyle textStyle,
  })  : _text = text,
        _textStyle = textStyle,
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
          fontSize: width / 14,
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
