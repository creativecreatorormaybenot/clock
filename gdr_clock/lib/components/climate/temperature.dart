import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:gdr_clock/clock.dart';

class AnimatedTemperature extends ImplicitlyAnimatedWidget {
  final ClockModel model;

  final Map<ClockColor, Color> palette;

  const AnimatedTemperature({
    Key key,
    Curve curve = Curves.decelerate,
    Duration duration = const Duration(seconds: 1),
    @required this.model,
    @required this.palette,
  })  : assert(model != null),
        assert(palette != null),
        super(key: key, curve: curve, duration: duration);

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
      textColor: widget.palette[ClockColor.text],
      tubeColor: widget.palette[ClockColor.thermometerTube],
      mountColor: widget.palette[ClockColor.thermometerMount],
      backgroundPrimaryColor: widget.palette[ClockColor.thermometerBackgroundPrimary],
      backgroundSecondaryColor: widget.palette[ClockColor.thermometerBackgroundSecondary],
      borderColor: widget.palette[ClockColor.thermometerBorder],
      bradColor: widget.palette[ClockColor.brad],
      bradHighlightColor: widget.palette[ClockColor.bradHighlight],
      temperatureColor: widget.palette[ClockColor.thermometerTemperature],
      maxTemperatureColor: widget.palette[ClockColor.thermometerTemperatureMax],
      minTemperatureColor: widget.palette[ClockColor.thermometerTemperatureMin],
      bracketColor: widget.palette[ClockColor.thermometerBracket],
      bracketHighlightColor: widget.palette[ClockColor.bradHighlight],
    );
  }
}

class Temperature extends LeafRenderObjectWidget {
  final TemperatureUnit unit;
  final String unitString;

  final double temperature, low, high;

  final Color textColor,
      tubeColor,
      mountColor,
      backgroundPrimaryColor,
      backgroundSecondaryColor,
      borderColor,
      bradColor,
      bradHighlightColor,
      temperatureColor,
      maxTemperatureColor,
      minTemperatureColor,
      bracketColor,
      bracketHighlightColor;

  Temperature({
    Key key,
    @required this.unit,
    @required this.unitString,
    @required this.temperature,
    @required this.low,
    @required this.high,
    @required this.textColor,
    @required this.tubeColor,
    @required this.mountColor,
    @required this.backgroundPrimaryColor,
    @required this.backgroundSecondaryColor,
    @required this.borderColor,
    @required this.bradColor,
    @required this.bradHighlightColor,
    @required this.temperatureColor,
    @required this.maxTemperatureColor,
    @required this.minTemperatureColor,
    @required this.bracketColor,
    @required this.bracketHighlightColor,
  })  : assert(unit != null),
        assert(unitString != null),
        assert(temperature != null),
        assert(low != null),
        assert(high != null),
        assert(textColor != null),
        assert(tubeColor != null),
        assert(mountColor != null),
        assert(backgroundPrimaryColor != null),
        assert(backgroundSecondaryColor != null),
        assert(borderColor != null),
        assert(bradColor != null),
        assert(bradHighlightColor != null),
        assert(temperatureColor != null),
        assert(maxTemperatureColor != null),
        assert(minTemperatureColor != null),
        assert(bracketColor != null),
        assert(bradHighlightColor != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTemperature(
      unit: unit,
      unitString: unitString,
      temperature: temperature,
      low: low,
      high: high,
      textColor: textColor,
      tubeColor: tubeColor,
      mountColor: mountColor,
      backgroundPrimaryColor: backgroundPrimaryColor,
      backgroundSecondaryColor: backgroundSecondaryColor,
      borderColor: borderColor,
      bradColor: bradColor,
      bradHighlightColor: bradHighlightColor,
      temperatureColor: temperatureColor,
      maxTemperatureColor: maxTemperatureColor,
      minTemperatureColor: minTemperatureColor,
      bracketColor: bracketColor,
      bracketHighlightColor: bracketHighlightColor,
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
      ..textColor = textColor
      ..tubeColor = tubeColor
      ..mountColor = mountColor
      ..backgroundPrimaryColor = backgroundPrimaryColor
      ..backgroundSecondaryColor = backgroundSecondaryColor
      ..borderColor = borderColor
      ..bradColor = bradColor
      ..bradHighlightColor = bradHighlightColor
      ..temperatureColor = temperatureColor
      ..maxTemperatureColor = maxTemperatureColor
      ..minTemperatureColor = minTemperatureColor
      ..bracketColor = bracketColor
      ..bracketHighlightColor = bracketHighlightColor;
  }
}

class RenderTemperature extends RenderCompositionChild {
  static const temperatureScale = {
    TemperatureUnit.celsius: [-16, 50],
    TemperatureUnit.fahrenheit: [3, 122],
  };

  RenderTemperature({
    TemperatureUnit unit,
    String unitString,
    double temperature,
    double low,
    double high,
    Color textColor,
    Color tubeColor,
    Color mountColor,
    Color backgroundPrimaryColor,
    Color backgroundSecondaryColor,
    Color borderColor,
    Color bradColor,
    Color bradHighlightColor,
    Color temperatureColor,
    Color maxTemperatureColor,
    Color minTemperatureColor,
    Color bracketColor,
    Color bracketHighlightColor,
  })  : _unit = unit,
        _unitString = unitString,
        _temperature = temperature,
        _low = low,
        _high = high,
        _textColor = textColor,
        _tubeColor = tubeColor,
        _mountColor = mountColor,
        _backgroundPrimaryColor = backgroundPrimaryColor,
        _backgroundSecondaryColor = backgroundSecondaryColor,
        _borderColor = borderColor,
        _bradColor = bradColor,
        _bradHighlightColor = bradHighlightColor,
        _temperatureColor = temperatureColor,
        _maxTemperatureColor = maxTemperatureColor,
        _minTemperatureColor = minTemperatureColor,
        _bracketColor = bracketColor,
        _bracketHighlightColor = bracketHighlightColor,
        super(ClockComponent.temperature);

  TemperatureUnit _unit;

  set unit(TemperatureUnit unit) {
    if (unit != _unit) markNeedsPaint();

    _unit = unit;
  }

  String _unitString;

  set unitString(String unitString) {
    if (_unitString != unitString) markNeedsPaint();

    _unitString = unitString;
  }

  double _temperature, _low, _high;

  set temperature(double temperature) {
    if (_temperature != temperature) markNeedsPaint();

    _temperature = temperature;
  }

  set low(double low) {
    if (_low != low) markNeedsPaint();

    _low = low;
  }

  set high(double high) {
    if (_high != high) markNeedsPaint();

    _high = high;
  }

  Color _textColor,
      _tubeColor,
      _mountColor,
      _backgroundPrimaryColor,
      _backgroundSecondaryColor,
      _borderColor,
      _bradColor,
      _bradHighlightColor,
      _temperatureColor,
      _maxTemperatureColor,
      _minTemperatureColor,
      _bracketColor,
      _bracketHighlightColor;

  set textColor(Color textColor) {
    if (_textColor != textColor) markNeedsPaint();

    _textColor = textColor;
  }

  set tubeColor(Color tubeColor) {
    if (_tubeColor != tubeColor) markNeedsPaint();

    _tubeColor = tubeColor;
  }

  set mountColor(Color mountColor) {
    if (_mountColor != mountColor) markNeedsPaint();

    _mountColor = mountColor;
  }

  set backgroundPrimaryColor(Color backgroundPrimaryColor) {
    if (_backgroundPrimaryColor != backgroundPrimaryColor) markNeedsPaint();

    _backgroundPrimaryColor = backgroundPrimaryColor;
  }

  set backgroundSecondaryColor(Color backgroundSecondaryColor) {
    if (_backgroundSecondaryColor != backgroundSecondaryColor) markNeedsPaint();

    _backgroundSecondaryColor = backgroundSecondaryColor;
  }

  set borderColor(Color borderColor) {
    if (_borderColor != borderColor) markNeedsPaint();

    _borderColor = borderColor;
  }

  set bradColor(Color bradColor) {
    if (_bradColor != bradColor) markNeedsPaint();

    _bradColor = bradColor;
  }

  set bradHighlightColor(Color bradHighlightColor) {
    if (_bradHighlightColor != bradHighlightColor) markNeedsPaint();

    _bradHighlightColor = bradHighlightColor;
  }

  set temperatureColor(Color temperatureColor) {
    if (_temperatureColor != temperatureColor) markNeedsPaint();

    _temperatureColor = temperatureColor;
  }

  set maxTemperatureColor(Color maxTemperatureColor) {
    if (_maxTemperatureColor != maxTemperatureColor) markNeedsPaint();

    _maxTemperatureColor = maxTemperatureColor;
  }

  set minTemperatureColor(Color minTemperatureColor) {
    if (_minTemperatureColor != minTemperatureColor) markNeedsPaint();

    _minTemperatureColor = minTemperatureColor;
  }

  set bracketColor(Color bracketColor) {
    if (_bracketColor != bracketColor) markNeedsPaint();

    _bracketColor = bracketColor;
  }

  set bracketHighlightColor(Color bracketHighlightColor) {
    if (_bracketHighlightColor != bracketHighlightColor) markNeedsPaint();

    _bracketHighlightColor = bracketHighlightColor;
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = Size(constraints.biggest.width, constraints.biggest.height / 1.2);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final area = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.width / 36));

    //<editor-fold desc="Background">
    final backgroundGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
      _backgroundPrimaryColor,
      _backgroundSecondaryColor,
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
          ..color = _borderColor
          // Not using strokeWidth 0.0 because that does not seem to scale with smaller canvas size,
          // i.e. 0 < strokeWidth < 1 is actually thinner than strokeWidth = 0.0, strangely.
          ..strokeWidth = size.height / 1e3);

    //<editor-fold desc="Some kind of brad nails at the top and bottom">
    final bradRadius = size.width / 29,
        // Lighter in the center to give some depth based on the lighting
        bradGradient = RadialGradient(colors: [
      _bradColor,
      _bradHighlightColor,
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
        text: _unitString,
        style: TextStyle(
          color: _textColor,
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

    _drawLines(canvas, lines);

    final tubeWidth = bradRadius * 1.2;

    //<editor-fold desc="Glass tube">
    final tubePaint = Paint()
      ..color = _tubeColor
      ..strokeWidth = tubeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tube.startOffset(dx: size.width / 2), tube.endOffset(dx: size.width / 2), tubePaint);
    //</editor-fold>

    _drawTemperature(
      canvas,
      tube,
      lines,
      tubeWidth * .56,
      _high,
      _maxTemperatureColor,
      text: 'max',
      textLeft: false,
    );
    _drawTemperature(
      canvas,
      tube,
      lines,
      tubeWidth * .85,
      _temperature,
      _temperatureColor,
    );
    _drawTemperature(
      canvas,
      tube,
      lines,
      tubeWidth * .56,
      _low,
      _minTemperatureColor,
      text: 'min',
    );

    //<editor-fold desc="Mount">
    () {
      final paint = Paint()
            ..color = _mountColor
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
    final bracketGradient = LinearGradient(
            // Again, highlight in the center to show that the metal is shining.
            colors: [
          _bradHighlightColor,
          _bracketColor,
          _bradHighlightColor,
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

  void _drawLines(Canvas canvas, Line constraints) {
    final paint = Paint()
      ..color = _textColor
      ..strokeWidth = size.height / 1e3;

    final majorValue = _unit == TemperatureUnit.fahrenheit ? 20 : 10, intermediateValue = majorValue / 2, minorValue = intermediateValue / 5;

    final fontSize = size.width / 7.4,
        fontIndent = fontSize / 9,
        style = TextStyle(
      color: _textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );

    final minMax = temperatureScale[_unit], min = minMax[0], max = minMax[1], difference = constraints.extent / max.difference(min) * minorValue;

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

  void _drawTemperature(Canvas canvas, Line tube, Line lines, double strokeWidth, double temperature, Color color, {String text, bool textLeft = true}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final currentScale = temperatureScale[_unit],
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
            backgroundColor: _tubeColor.withOpacity(.52),
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
          ..color = _textColor
          ..strokeWidth = size.height / 368);
  }
}
