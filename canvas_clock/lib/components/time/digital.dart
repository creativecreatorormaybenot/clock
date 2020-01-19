import 'package:canvas_clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/model.dart';

class AnimatedDigitalTime extends AnimatedWidget {
  final Animation<double> animation;

  final ClockModel model;
  final Map<ClockColor, Color> palette;

  const AnimatedDigitalTime({
    Key key,
    @required this.animation,
    @required this.model,
    @required this.palette,
  })  : assert(animation != null),
        assert(model != null),
        assert(palette != null),
        super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final time = DateTime.now();

    return DigitalTime(
      hour: time.hour,
      minute: time.minute,
      minuteProgress: animation.value,
      use24HourFormat: model.is24HourFormat,
      textColor: palette[ClockColor.digitalTimeText],
    );
  }
}

class DigitalTime extends LeafRenderObjectWidget {
  /// [hour] is in 24 hour format.
  final int hour, minute;

  /// Range from `0` to `1` ([minuteProgress] >= 0 ∧ [minuteProgress] <= 1)
  /// indicating how far the current minute has progressed.
  ///
  /// This should not be used as an accurate representation of the current second.
  final double minuteProgress;

  final bool use24HourFormat;

  final Color textColor;

  DigitalTime({
    Key key,
    @required this.textColor,
    @required this.minuteProgress,
    @required this.use24HourFormat,
    @required this.hour,
    @required this.minute,
  })  : assert(textColor != null),
        assert(minuteProgress != null),
        assert(hour != null),
        assert(minute != null),
        assert(use24HourFormat != null),
        super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDigitalTime(
      textColor: textColor,
      minuteProgress: minuteProgress,
      use24HourFormat: use24HourFormat,
      hour: hour,
      minute: minute,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDigitalTime renderObject) {
    renderObject
      ..textColor = textColor
      ..minuteProgress = minuteProgress
      ..use24HourFormat = use24HourFormat
      ..hour = hour
      ..minute = minute;
  }
}

/// Provides child with data necessary to position what it draws
/// properly given full size constraints.
///
/// This allows the child to lay itself out when nothing in the
/// parent depends on the layout of the child.
/// Otherwise, the parent would be marked as needing to layout again,
/// which is bad performance wise.
class DigitalTimeParentData extends ClockChildrenParentData {
  Offset position;
}

class RenderDigitalTime extends RenderCompositionChild<ClockComponent, DigitalTimeParentData> {
  RenderDigitalTime({
    double minuteProgress,
    int hour,
    int minute,
    bool use24HourFormat,
    Color textColor,
  })  : _minuteProgress = minuteProgress,
        _hour = hour,
        _minute = minute,
        _use24HourFormat = use24HourFormat,
        _textColor = textColor,
        super(ClockComponent.digitalTime);

  double _minuteProgress;

  set minuteProgress(double value) {
    assert(value != null);

    if (_minuteProgress == value) {
      return;
    }

    _minuteProgress = value;
    // The layout depends on the time displayed.
    markNeedsLayout();
  }

  int _hour, _minute;

  set hour(int value) {
    assert(value != null);

    if (_hour == value) {
      return;
    }

    _hour = value;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  set minute(int value) {
    assert(value != null);

    if (_minute == value) {
      return;
    }

    _minute = value;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  bool _use24HourFormat;

  set use24HourFormat(bool value) {
    assert(value != null);

    if (_use24HourFormat == value) {
      return;
    }

    _use24HourFormat = value;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  Color _textColor;

  set textColor(Color value) {
    assert(value != null);

    if (_textColor == value) {
      return;
    }

    _textColor = value;
    markNeedsPaint();
  }

  TextPainter _timePainter, _amPmPainter;

  int get hour => _use24HourFormat ? _hour : _hour % 12;

  String get time => '${hour.twoDigitTime}:${_minute.twoDigitTime}';

  String get amPm => _hour > 12 ? 'PM' : 'AM';

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
      ..label = 'Digital clock showing $time${_use24HourFormat ? '' : ' $amPm'}'
      ..isReadOnly = true
      ..textDirection = TextDirection.ltr;
  }

  /// Determines for how many seconds the moving item (AM/PM or the bar)
  /// should move at the start and end of a minute.
  /// This time is taken both at the start and the end for a total of
  /// [fastMoveSeconds] * 2 per minute.
  static const double fastMoveSeconds = 5;

  TweenSequence yMovementSequence;

  @override
  void performLayout() {
    // This should ideally not be the whole screen,
    // but rather a constrained size, like the width
    // of the weather component.
    final given = constraints.biggest;

    _timePainter = TextPainter(
      text: TextSpan(
        text: time,
        style: TextStyle(
          color: _textColor,
          fontSize: given.width / 7.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    _amPmPainter = TextPainter(
      text: TextSpan(
        text: amPm,
        style: TextStyle(
          color: _textColor,
          fontSize: given.width / 13,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    _amPmPainter.layout(maxWidth: given.width / 2);
    _timePainter.layout(maxWidth: given.width - _amPmPainter.width);

    size = Size(
      _timePainter.width +
          // This is always correct because the bar that is used instead of AM-PM
          // should have the same width as the text.
          _amPmPainter.width,
      _timePainter.height,
    );

    // The widget should be painted centered about the position.
    compositionData.offset = compositionData.position - size.offset / 2;

    final
        // The text should go fully off screen about the new minute.
        h = _amPmPainter.height / 2,
        inDistance = _timePainter.text.style.fontSize / 1.5;

    // Describes the center position of the element.
    yMovementSequence = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: size.height + h, end: size.height + h - inDistance).chain(
          CurveTween(
            curve: const Cubic(.32, .62, .06, .95),
          ),
        ),
        weight: fastMoveSeconds,
      ),
      TweenSequenceItem(
        tween: Tween(begin: size.height + h - inDistance, end: inDistance - h),
        weight: 60 - fastMoveSeconds * 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: inDistance - h, end: -h).chain(
          CurveTween(
            curve: const Cubic(.91, .09, .91, .54),
          ),
        ),
        weight: fastMoveSeconds,
      ),
    ]);
  }

  double get movementY => yMovementSequence.transform(_minuteProgress);

  static const barPaddingFactor = .07;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // Need to clip because the moving element can be out of view.
    canvas.clipRect(Offset.zero & size);

    _timePainter.paint(canvas, Offset.zero);

    if (_use24HourFormat) {
      final width = _amPmPainter.size.width;

      canvas.drawRect(
          Rect.fromPoints(
            Offset(_timePainter.width + width * barPaddingFactor, movementY),
            Offset(_timePainter.width + width * (1 - barPaddingFactor), size.height),
          ),
          Paint()
            ..color = _textColor
            ..strokeWidth = size.height / 26);
    } else {
      _amPmPainter.paint(canvas, Offset(_timePainter.width, movementY - _amPmPainter.height / 2));
    }

    canvas.restore();
  }
}
