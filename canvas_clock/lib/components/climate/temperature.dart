import 'dart:math';

import 'package:canvas_clock/clock.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

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
      borderColor: widget.palette[ClockColor.border],
      bradColor: widget.palette[ClockColor.brad],
      bradHighlightColor: widget.palette[ClockColor.bradHighlight],
      temperatureColor: widget.palette[ClockColor.temperature],
      maxTemperatureColor: widget.palette[ClockColor.temperatureMax],
      minTemperatureColor: widget.palette[ClockColor.temperatureMin],
      bracketColor: widget.palette[ClockColor.bracket],
      bracketHighlightColor: widget.palette[ClockColor.bradHighlight],
      shadowColor: widget.palette[ClockColor.shadow],
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
      bracketHighlightColor,
      shadowColor;

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
    @required this.shadowColor,
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
        assert(shadowColor != null),
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
      shadowColor: shadowColor,
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
      ..bracketHighlightColor = bracketHighlightColor
      ..shadowColor = shadowColor;
  }
}

class RenderTemperature extends RenderCompositionChild<ClockComponent, ClockChildrenParentData> {
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
    Color shadowColor,
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
        _shadowColor = shadowColor,
        super(ClockComponent.temperature);

  TemperatureUnit _unit;

  set unit(TemperatureUnit value) {
    assert(value != null);

    if (_unit == value) {
      return;
    }

    _unit = value;
    markNeedsPaint();
  }

  String _unitString;

  set unitString(String value) {
    assert(value != null);

    if (_unitString == value) {
      return;
    }

    _unitString = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  double _temperature, _low, _high;

  set temperature(double value) {
    assert(value != null);

    if (_temperature == value) {
      return;
    }

    _temperature = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  set low(double value) {
    assert(value != null);

    if (_low == value) {
      return;
    }

    _low = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  set high(double value) {
    assert(value != null);

    if (_high == value) {
      return;
    }

    _high = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
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
      _bracketHighlightColor,
      _shadowColor;

  set textColor(Color value) {
    assert(value != null);

    if (_textColor == value) {
      return;
    }

    _textColor = value;
    markNeedsPaint();
  }

  set tubeColor(Color value) {
    assert(value != null);

    if (_tubeColor == value) {
      return;
    }

    _tubeColor = value;
    markNeedsPaint();
  }

  set mountColor(Color value) {
    assert(value != null);

    if (_mountColor == value) {
      return;
    }

    _mountColor = value;
    markNeedsPaint();
  }

  set backgroundPrimaryColor(Color value) {
    assert(value != null);

    if (_backgroundPrimaryColor == value) {
      return;
    }

    _backgroundPrimaryColor = value;
    markNeedsPaint();
  }

  set backgroundSecondaryColor(Color value) {
    assert(value != null);

    if (_backgroundSecondaryColor == value) {
      return;
    }

    _backgroundSecondaryColor = value;
    markNeedsPaint();
  }

  set borderColor(Color value) {
    assert(value != null);

    if (_borderColor == value) {
      return;
    }

    _borderColor = value;
    markNeedsPaint();
  }

  set bradColor(Color value) {
    assert(value != null);

    if (_bradColor == value) {
      return;
    }

    _bradColor = value;
    markNeedsPaint();
  }

  set bradHighlightColor(Color value) {
    assert(value != null);

    if (_bradHighlightColor == value) {
      return;
    }

    _bradHighlightColor = value;
    markNeedsPaint();
  }

  set temperatureColor(Color value) {
    assert(value != null);

    if (_temperatureColor == value) {
      return;
    }

    _temperatureColor = value;
    markNeedsPaint();
  }

  set maxTemperatureColor(Color value) {
    assert(value != null);

    if (_maxTemperatureColor == value) {
      return;
    }

    _maxTemperatureColor = value;
    markNeedsPaint();
  }

  set minTemperatureColor(Color value) {
    assert(value != null);

    if (_minTemperatureColor == value) {
      return;
    }

    _minTemperatureColor = value;
    markNeedsPaint();
  }

  set bracketColor(Color value) {
    assert(value != null);

    if (_bracketColor == value) {
      return;
    }

    _bracketColor = value;
    markNeedsPaint();
  }

  set bracketHighlightColor(Color value) {
    assert(value != null);

    if (_bracketHighlightColor == value) {
      return;
    }

    _bracketHighlightColor = value;
    markNeedsPaint();
  }

  set shadowColor(Color value) {
    assert(value != null);

    if (_shadowColor == value) {
      return;
    }

    _shadowColor = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

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
      ..label = 'Thermometer showing a temperature of $_temperature$_unitString, a high of $_high$_unitString, and a low of $_low$_unitString';
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
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
          ..strokeWidth = size.height / 649);

    //<editor-fold desc="Some kind of brad nails at the top and bottom">
    final bradRadius = size.width / 29,
        // Lighter in the center to give some depth based on the lighting
        bradGradient = RadialGradient(colors: [
      _bradColor,
      _bradHighlightColor,
    ]),
        bradIndent = size.width / 11;
    () {
      final elevation = size.width / 186;

      final topRect = Rect.fromCircle(center: Offset(size.width / 2, bradIndent), radius: bradRadius), topPath = Path()..addOval(topRect), topPaint = Paint()..shader = bradGradient.createShader(topRect);
      _drawTransformedShadow(canvas, topPath, elevation);
      canvas.drawPath(topPath, topPaint);

      final bottomRect = Rect.fromCircle(center: Offset(size.width / 2, size.height - bradIndent), radius: bradRadius),
          bottomPath = Path()..addOval(bottomRect),
          bottomPaint = Paint()..shader = bradGradient.createShader(bottomRect);
      _drawTransformedShadow(canvas, bottomPath, elevation);
      canvas.drawPath(bottomPath, bottomPaint);
    }();
    //</editor-fold>

    //<editor-fold desc="Unit">
    final unitIndent = size.width / 8,
        unitPainter = TextPainter(
      text: TextSpan(
        text: '$_unitString',
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
        mount = Line1d.fromEE(end: size.height - bradIndent * addedIndentFactor, extent: size.height / 13),
        tube = Line1d(end: mount.start, start: unitIndent + unitPainter.height / 1.4 + bradIndent * addedIndentFactor),
        brackets = Line1d.fromSEI(start: tube.start, end: tube.end, indent: tube.extent / 7.42),
        lines = Line1d.fromSEI(start: brackets.start, end: brackets.end, indent: -mount.extent / 3);

    _drawLines(canvas, lines);

    final tubeWidth = bradRadius * 1.2, tubeElevation = size.width / 114;

    //<editor-fold desc="Glass tube">
    // I do not want to pass the variables from above,
    // so this is more convenient.
    final tubePaint = Paint()..color = _tubeColor,
        tubeStart = tube.startOffset(dx: size.width / 2),
        tubeEnd = tube.endOffset(dx: size.width / 2),
        tubePath = Path()
          ..moveTo(
            tubeEnd.dx - tubeWidth / 2,
            tubeEnd.dy,
          )
          ..lineTo(
            tubeStart.dx - tubeWidth / 2,
            tubeStart.dy,
          )
          ..halfCircleTo(
            tubeStart.dx + tubeWidth / 2,
            tubeStart.dy,
          )
          ..lineTo(
            tubeEnd.dx + tubeWidth / 2,
            tubeEnd.dy,
          )
          ..halfCircleTo(
            tubeEnd.dx - tubeWidth / 2,
            tubeEnd.dy,
          )
          ..close();
    //</editor-fold>

    //<editor-fold desc="Mount">
    final mountPaint = Paint()..color = _mountColor;
    Path mountPath;

    // I do not want to pass the variables from above to a method,
    // so this is more convenient :)
    () {
      final w = bradRadius * 1.33, start = mount.startOffset(dx: size.width / 2), end = mount.endOffset(dx: size.width / 2);
      mountPath = Path()
        ..moveTo(end.dx - w / 2, end.dy)
        // Square cap at the top
        ..lineTo(
          start.dx - w / 2,
          // Adding the width to the y value here
          // because there should be a square cap,
          // which extends beyond the end point.
          start.dy - w / 2,
        )
        ..lineTo(
          start.dx + w / 2,
          start.dy - w / 2,
        )
        ..lineTo(end.dx + w / 2, end.dy)
        // Round cap at the bottom
        ..halfCircleTo(
          // This is obviously the starting point again.
          end.dx - w / 2,
          end.dy,
        )
        ..close();

      // The idea here is to draw a shadow for the whole tube
      // at once, which includes the mount. Otherwise, the shadows
      // of the tube and the mount would overlap, which looks
      // unnatural.
      _drawTransformedShadow(
          canvas,
          Path.from(tubePath)
            ..extendWithPath(
              mountPath,
              Offset.zero,
            ),
          tubeElevation);

      canvas.drawPath(tubePath, tubePaint);
    }();
    //</editor-fold>

    final smallStrokeWidth = tubeWidth * .56;
    _drawTemperature(
      canvas,
      tube,
      lines,
      smallStrokeWidth,
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
      horizontalLineWidth: tubeWidth,
    );
    _drawTemperature(
      canvas,
      tube,
      lines,
      smallStrokeWidth,
      _low,
      _minTemperatureColor,
      text: 'min',
    );

    // The mount should be drawn over the liquid at the bottom :)
    canvas.drawPath(mountPath, mountPaint);

    //<editor-fold desc="Brackets">
    final bracketGradient = LinearGradient(
            // Again, highlight in the center to show that the metal is shining.
            colors: [
          _bracketHighlightColor,
          _bracketColor,
          _bracketHighlightColor,
        ]),
        bracketWidth = tubeWidth * 1.42,
        bracketSize = Size(bracketWidth, bracketWidth / 2.3);
    () {
      final dx = size.width / 2 - bracketWidth / 2, elevation = size.width / 91;

      final startRect = brackets.startOffset(dx: dx) & bracketSize, startPath = Path()..addRect(startRect), startPaint = Paint()..shader = bracketGradient.createShader(startRect);
      _drawTransformedShadow(canvas, startPath, elevation);
      canvas.drawPath(startPath, startPaint);

      final endRect = brackets.endOffset(dx: dx) & bracketSize, endPath = Path()..addRect(endRect), endPaint = Paint()..shader = bracketGradient.createShader(endRect);
      _drawTransformedShadow(canvas, endPath, elevation);
      canvas.drawPath(endPath, endPaint);
    }();
    //</editor-fold>

    canvas.restore();
  }

  /// The position of the light source casting shadows of some elements.
  /// At the moment, it is the center of the thermometer as the position
  /// and shadows are drawn for the brackets, brads, and the mount.
  ///
  /// This will not make the shadows appear exactly as though the light
  /// source was at [lightSourcePosition] but rather shift them a tiny bit,
  /// which makes the shadows in here fit more with the rest of the shadows
  /// in the clock face.
  Offset get lightSourcePosition => Offset(size.width / 2, size.height / 2);

  /// Transforms the given [path] and translates the [canvas] in a way
  /// that positions the light source of the shadow at a particular point
  /// of the thermometer ([lightSourcePosition]), even though the path
  /// was originally drawn with the top left of the thermometer
  /// being (0, 0).
  void _drawTransformedShadow(Canvas canvas, Path path, double elevation) {
    canvas.save();

    final light = lightSourcePosition, transformedPath = path.transform(Matrix4.translation((-light).vector3).storage);

    canvas.translate(light.dx, light.dy);
    canvas.drawShadow(transformedPath, _shadowColor, elevation, false);

    canvas.restore();
  }

  void _drawLines(Canvas canvas, Line1d constraints) {
    final linePaint = Paint()
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
        final line = Line1d.fromCenter(center: size.width / 2, extent: size.width / 1.46);

        canvas.drawLine(line.startOffset(dy: h), line.endOffset(dy: h), linePaint);

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
        final line = Line1d.fromCenter(center: size.width / 2, extent: size.width / 2.1);

        canvas.drawLine(line.startOffset(dy: h), line.endOffset(dy: h), linePaint);
      } else if (i % minorValue == 0) {
        final line = Line1d.fromCenter(center: size.width / 2, extent: size.width / 3.3);

        canvas.drawLine(line.startOffset(dy: h), line.endOffset(dy: h), linePaint);
      }

      h -= difference;
    }
  }

  void _drawTemperature(
    Canvas canvas,
    Line1d tube,
    Line1d lines,
    double strokeWidth,
    double temperature,
    Color color, {
    String text,
    bool textLeft = true,
    double horizontalLineWidth,
  }) {
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
    final horizontalLine = Line1d.fromCenter(
      center: offset.dx,
      extent: horizontalLineWidth ?? strokeWidth,
    );
    canvas.drawLine(
        horizontalLine.startOffset(dy: offset.dy),
        horizontalLine.endOffset(dy: offset.dy),
        Paint()
          ..color = _textColor
          ..strokeWidth = size.height / 368);
  }
}
