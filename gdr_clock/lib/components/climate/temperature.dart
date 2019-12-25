import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';

class Temperature extends LeafRenderObjectWidget {
  final TemperatureUnit unit;
  final String unitString;
  final double temperature, low, high;

  Temperature({
    Key key,
    @required this.unit,
    @required this.unitString,
    @required this.temperature,
    @required this.low,
    @required this.high,
  })  : assert(unit != null),
        assert(unitString != null),
        assert(temperature != null),
        assert(low != null),
        assert(high != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTemperature(
      unit: unit,
      unitString: unitString,
      temperature: temperature,
      low: low,
      high: high,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTemperature renderObject) {
    renderObject
      ..unit = unit
      ..unitString = unitString
      ..temperature = temperature
      ..low = low
      ..high = high;
  }
}

class RenderTemperature extends RenderCompositionChild {
  RenderTemperature({
    this.unit,
    this.unitString,
    this.temperature,
    this.low,
    this.high,
  }) : super(ClockComponent.temperature);

  TemperatureUnit unit;
  String unitString;
  double temperature, low, high;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = Size(constraints.biggest.width, constraints.biggest.height / 1.3);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xff000000));

    final unitIndent = size.width / 6,
        unitPainter = TextPainter(
      text: TextSpan(
        text: unitString,
        style: TextStyle(
          color: const Color(0xff000000),
          fontSize: size.width / 5,
        ),
      ),
      textDirection: TextDirection.ltr,
    ), freeUnitWidth = size.width - unitIndent * 2;
    unitPainter.layout(maxWidth: freeUnitWidth);
    unitPainter.paint(canvas, Offset(unitIndent + (freeUnitWidth / 2 - unitPainter.width / 2), unitIndent));

    canvas.restore();
  }
}
