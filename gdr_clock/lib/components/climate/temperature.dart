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
      ..high = high
      ..markNeedsPaint();
  }
}

class RenderTemperature extends RenderCompositionChild {
  static const temperatureScale = {
    TemperatureUnit.celsius: [-16, 50],
    TemperatureUnit.fahrenheit: [3, 122],
  };

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
    size = Size(constraints.biggest.width, constraints.biggest.height / 1.2);
  }

  static const tubeColor = Color(0xffffe3d1), mountColor = Color(0xff996515);

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final area = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width / 36));

    // Background
    final gradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [
      Color(0xffcc9933),
      Color(0xffc9bd6c),
    ]);
    canvas.drawRRect(
        area,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = gradient.createShader(Offset.zero & size));

    // Border
    canvas.drawRRect(
        area,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xff000000));

    // Some kind of brad nails at the top and bottom
    final bradRadius = size.width / 29,
        // Lighter in the center to give some depth based on the lighting
        bradGradient = const RadialGradient(colors: [
      Color(0xff898984),
      Color(0xff43464b),
    ]),
        bradIndent = size.width / 11;
    () {
      final topRect = Rect.fromCircle(center: Offset(size.width / 2, bradIndent), radius: bradRadius);
      canvas.drawOval(topRect, Paint()..shader = bradGradient.createShader(topRect));

      final bottomRect = Rect.fromCircle(center: Offset(size.width / 2, size.height - bradIndent), radius: bradRadius);
      canvas.drawOval(bottomRect, Paint()..shader = bradGradient.createShader(bottomRect));
    }();

    final unitIndent = size.width / 8,
        unitPainter = TextPainter(
      text: TextSpan(
        text: unitString,
        style: TextStyle(
          color: const Color(0xff000000),
          fontSize: size.width / 6,
        ),
      ),
      textDirection: TextDirection.ltr,
    ),
        freeUnitWidth = size.width - unitIndent * 2;
    unitPainter.layout(maxWidth: freeUnitWidth);
    unitPainter.paint(canvas, Offset(unitIndent + (freeUnitWidth / 2 - unitPainter.width / 2), unitIndent + bradIndent));

    // Constraints for the positioning of the numbers, lines, brackets, and tube.
    final addedIndentFactor = 3.2,
        mount = Line.fromEE(end: size.height - bradIndent * addedIndentFactor, extent: size.height / 13),
        tube = Line(end: mount.start, start: unitIndent + unitPainter.height / 1.4 + bradIndent * addedIndentFactor),
        brackets = Line.fromSEI(start: tube.start, end: tube.end, indent: tube.extent / 6.42),
        lines = Line.fromSEI(start: brackets.start, end: brackets.end, indent: -mount.extent / 3);

    // Glass tube
    canvas.drawLine(
        tube.startOffset(dx: size.width / 2),
        tube.endOffset(dx: size.width / 2),
        Paint()
          ..color = tubeColor
          ..strokeWidth = bradRadius * 1.2
          ..strokeCap = StrokeCap.round);

    // Mount
    () {
      final paint = Paint()
            ..color = mountColor
            ..strokeWidth = bradRadius * 1.33
            ..strokeCap = StrokeCap.round,
          start = mount.startOffset(dx: size.width / 2);

      canvas.drawLine(
        start,
        mount.endOffset(dx: size.width / 2),
        paint,
      );

      // Add square cap at the top
      canvas.drawLine(
        start,
        start,
        paint..strokeCap = StrokeCap.square,
      );
    }();

    canvas.restore();
  }
}
