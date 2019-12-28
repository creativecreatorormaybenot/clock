import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';

class AnimatedTemperature extends ImplicitlyAnimatedWidget {
  final ClockModel model;

  const AnimatedTemperature({
    Key key,
    Curve curve = Curves.decelerate,
    Duration duration = const Duration(seconds: 1),
    @required this.model,
  }) : super(key: key, curve: curve, duration: duration);

  @override
  _AnimatedTemperatureState createState() {
    return _AnimatedTemperatureState();
  }
}

class _AnimatedTemperatureState extends AnimatedWidgetBaseState<AnimatedTemperature> {
  Tween<double> _temperature, _low, _high;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _temperature = visitor(_temperature, widget.model.temperature, (value) => Tween<double>(begin: value as double)) as Tween<double>;
    _low = visitor(_low, widget.model.low, (value) => Tween<double>(begin: value as double)) as Tween<double>;
    _high = visitor(_high, widget.model.high, (value) => Tween<double>(begin: value as double)) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    return Temperature(
      unit: widget.model.unit,
      unitString: widget.model.unitString,
      temperature: _temperature?.evaluate(animation) ?? 0,
      low: _low?.evaluate(animation) ?? 0,
      high: _high?.evaluate(animation) ?? 0,
    );
  }
}

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

  static const tubeColor = Color(0xffffe3d1), mountColor = Color(0xffa38d1c);

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final area = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width / 36));

    //<editor-fold desc="Background">
    final backgroundGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [
      Color(0xffcc9933),
      Color(0xffc9bd6c),
    ]);
    canvas.drawRRect(
        area,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = backgroundGradient.createShader(Offset.zero & size));
    //</editor-fold>

    // Border
    canvas.drawRRect(
        area,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xff000000)
          // Not using strokeWidth 0.0 because that does not seem to scale with smaller canvas size,
          // i.e. 0 < strokeWidth < 1 is actually thinner than strokeWidth = 0.0, strangely.
          ..strokeWidth = size.height / 1e3);

    //<editor-fold desc="Some kind of brad nails at the top and bottom">
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
    //</editor-fold>

    //<editor-fold desc="Unit">
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
    //</editor-fold>

    // Constraints for the positioning of the numbers, lines, brackets, and tube.
    final addedIndentFactor = 3.2,
        mount = Line.fromEE(end: size.height - bradIndent * addedIndentFactor, extent: size.height / 13),
        tube = Line(end: mount.start, start: unitIndent + unitPainter.height / 1.4 + bradIndent * addedIndentFactor),
        brackets = Line.fromSEI(start: tube.start, end: tube.end, indent: tube.extent / 7.42),
        lines = Line.fromSEI(start: brackets.start, end: brackets.end, indent: -mount.extent / 3);

    _paintLines(canvas, lines);

    final tubeWidth = bradRadius * 1.2;

    //<editor-fold desc="Glass tube">
    final tubePaint = Paint()
      ..color = tubeColor
      ..strokeWidth = tubeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tube.startOffset(dx: size.width / 2), tube.endOffset(dx: size.width / 2), tubePaint);
    //</editor-fold>

    _paintTemperature(
      canvas,
      tube,
      lines,
      tubeWidth * .56,
      high,
      const Color(0x9cff3a4b),
      text: 'max',
      textLeft: false,
    );
    _paintTemperature(
      canvas,
      tube,
      lines,
      tubeWidth * .85,
      temperature,
      const Color(0xde6ab7ff),
    );
    _paintTemperature(
      canvas,
      tube,
      lines,
      tubeWidth * .56,
      low,
      const Color(0xae2a42ff),
      text: 'min',
    );

    //<editor-fold desc="Mount">
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
    //</editor-fold>

    //<editor-fold desc="Brackets">
    final bracketGradient = const LinearGradient(
            // Again, highlight in the center to show that the metal is shining.
            colors: [
          Color(0xff87898c),
          Color(0xffe0e1e2),
          Color(0xff87898c),
        ]),
        bracketWidth = tubeWidth * 1.42,
        bracketSize = Size(bracketWidth, bracketWidth / 2.3);
    () {
      final dx = size.width / 2 - bracketWidth / 2;

      final startRect = brackets.startOffset(dx: dx) & bracketSize;
      canvas.drawRect(startRect, Paint()..shader = bracketGradient.createShader(startRect));

      final endRect = brackets.endOffset(dx: dx) & bracketSize;
      canvas.drawRect(endRect, Paint()..shader = bracketGradient.createShader(endRect));
    }();
    //</editor-fold>

    canvas.restore();
  }

  void _paintLines(Canvas canvas, Line constraints) {
    final paint = Paint()
      ..color = const Color(0xff000000)
      ..strokeWidth = size.height / 1e3;

    final majorValue = unit == TemperatureUnit.fahrenheit ? 20 : 10, intermediateValue = majorValue / 2, minorValue = intermediateValue / 5;

    final fontSize = size.width / 7.4,
        fontIndent = fontSize / 9,
        style = TextStyle(
      color: const Color(0xff000000),
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );

    final minMax = temperatureScale[unit], min = minMax[0], max = minMax[1], difference = constraints.extent / max.difference(min) * minorValue;

    var h = constraints.end;
    for (var i = min; i <= max; i++) {
      if (i % minorValue != 0 && i % intermediateValue != 0 && i % majorValue != 0) continue;

      if (i % majorValue == 0) {
        final line = Line.fromCenter(center: size.width / 2, extent: size.width / 1.46);

        canvas.drawLine(line.startOffset(dy: h), line.endOffset(dy: h), paint);

        final text = i == 0 ? '00' : '${i.abs()}', left = text.substring(0, 1), right = text.substring(1);

        final leftPainter = TextPainter(
          text: TextSpan(
            text: left,
            style: style,
          ),
          textDirection: TextDirection.ltr,
        ),
            rightPainter = TextPainter(
          text: TextSpan(
            text: right,
            style: style,
          ),
          textDirection: TextDirection.ltr,
        );

        // If the digits do not fit roughly line.extent / 4, the design is screwed anyway, hence, no constraints here.
        leftPainter.layout();
        rightPainter.layout();

        // The TextPainters will return slightly larger sizes than actually visible and
        // this is supposed to compensate exactly that.
        final reduction = 1.14;

        leftPainter.paint(canvas, Offset(line.start + fontIndent, h - leftPainter.height / reduction));
        rightPainter.paint(canvas, Offset(line.end - fontIndent - rightPainter.width / reduction, h - rightPainter.height / reduction));
      } else if (i % intermediateValue == 0) {
        final line = Line.fromCenter(center: size.width / 2, extent: size.width / 2.1);

        canvas.drawLine(line.startOffset(dy: h), line.endOffset(dy: h), paint);
      } else if (i % minorValue == 0) {
        final line = Line.fromCenter(center: size.width / 2, extent: size.width / 3.3);

        canvas.drawLine(line.startOffset(dy: h), line.endOffset(dy: h), paint);
      }

      h -= difference;
    }
  }

  void _paintTemperature(Canvas canvas, Line tube, Line lines, double strokeWidth, double temperature, Color color, {String text, bool textLeft = true}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final currentScale = temperatureScale[unit],
        temperatureRange = currentScale[0].difference(currentScale[1]),
        currentTemperature = temperature - currentScale[0],
        offset = lines.startOffset(dx: size.width / 2) + Offset(0, lines.extent / temperatureRange * (temperatureRange - currentTemperature));

    // Bars
    canvas.drawLine(
      Offset(
        offset.dx,
        // Clamp the value in order to not exceed the tube's bounds.
        min(tube.end, max(tube.start, offset.dy)),
      ),
      // Go to the end of the tube, just so it is filled.
      tube.endOffset(dx: size.width / 2),
      paint,
    );

    // Do not show ticks nor text if the values exceed the thermometers scale.
    if (offset.dy < lines.start || offset.dy > lines.end) return;

    if (text != null) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size.width / 13,
            fontWeight: FontWeight.bold,
            backgroundColor: tubeColor.withOpacity(.52),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: size.width);

      final textPadding = size.width / 21;

      painter.paint(canvas, offset + Offset(textLeft ? -painter.width - textPadding : textPadding, -painter.height / 2));
    }

    // Add little tick marks to make it more clear what value this bar indicates.
    final horizontalLine = Line.fromCenter(center: offset.dx, extent: strokeWidth);
    canvas.drawLine(
        horizontalLine.startOffset(dy: offset.dy),
        horizontalLine.endOffset(dy: offset.dy),
        Paint()
          ..color = const Color(0xff000000)
          ..strokeWidth = size.height / 368);
  }
}
