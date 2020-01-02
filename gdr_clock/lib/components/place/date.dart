import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class UpdatedDate extends StatefulWidget {
  const UpdatedDate({Key key}) : super(key: key);

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
      timer = Timer(
          DateTime(time.year, time.month, time.day + 1).difference(time),
          update);
    });
  }

  @override
  Widget build(BuildContext context) => Date(
        text: '${time.month}/${time.day}/${time.year}',
        textStyle: const TextStyle(
          color: Color(0xff000000),
          fontWeight: FontWeight.bold,
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
      ..textStyle = textStyle
      ..markNeedsLayout();
  }
}

class RenderDate extends RenderCompositionChild {
  RenderDate({this.text, this.textStyle}) : super(ClockComponent.date);

  String text;
  TextStyle textStyle;

  TextPainter textPainter;

  @override
  void performLayout() {
    final width = constraints.biggest.width;

    textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
          fontSize: width / 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
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
