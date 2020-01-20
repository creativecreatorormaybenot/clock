import 'dart:async';

import 'package:canvas_clock/clock.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class UpdatedDate extends StatefulWidget {
  final Map<ClockColor, Color> palette;

  const UpdatedDate({
    Key key,
    @required this.palette,
  })  : assert(palette != null),
        super(key: key);

  @override
  State createState() => _UpdatedDateState();
}

class _UpdatedDateState extends State<UpdatedDate> {
  @override
  void initState() {
    super.initState();

    update();
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  DateTime time;
  Timer timer;

  void update() {
    time = DateTime.now();

    setState(() {
      // DateTime handles passing e.g. 32 as the day just fine, i.e. even when the day should actually roll over,
      // passing the previous day + 1 is fine because DateTime will convert it into the correct date anyway,
      // which means that the time difference here will always be correct.
      timer = Timer(DateTime(time.year, time.month, time.day + 1).difference(time), update);
    });
  }

  @override
  Widget build(BuildContext context) => Date(
        text: '${time.month}/${time.day}/${time.year}',
        textStyle: TextStyle(
          color: widget.palette[ClockColor.text],
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
        ),
      );
}

class Date extends LeafRenderObjectWidget {
  final String text;
  final TextStyle textStyle;

  Date({
    Key key,
    @required this.text,
    @required this.textStyle,
  })  : assert(text != null),
        assert(textStyle != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDate(
      text: text,
      textStyle: textStyle,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDate renderObject) {
    renderObject
      ..text = text
      ..textStyle = textStyle;
  }
}

class RenderDate extends RenderCompositionChild<ClockComponent, ClockChildrenParentData> {
  RenderDate({
    String text,
    TextStyle textStyle,
  })  : _text = text,
        _textStyle = textStyle,
        super(ClockComponent.date);

  String _text;

  set text(String value) {
    assert(value != null);

    if (_text == value) {
      return;
    }

    _text = value;
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
      ..label = 'Date is $_text';
  }

  @override
  void performLayout() {
    final width = constraints.biggest.width;

    _textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: _textStyle.copyWith(
          fontSize: width / 13.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout(maxWidth: width);

    // See https://github.com/flutter/flutter/issues/49183.
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
