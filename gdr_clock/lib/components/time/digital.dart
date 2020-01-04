import 'package:flutter/widgets.dart';
import 'package:gdr_clock/clock.dart';

class DigitalTime extends LeafRenderObjectWidget {
  final int hour, minute;

  /// Range from `0` to `1` indicating how far the current minute has progressed.
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

class RenderDigitalTime extends RenderCompositionChild {
  RenderDigitalTime({
    double minuteProgress,
    int hour,
    int minute,
    bool use24HourFormat,
    Color textColor,
  })  :
        _minuteProgress = minuteProgress,
  _hour = hour,
  _minute = minute,
  _use24HourFormat = use24HourFormat,
        _textColor = textColor,
        super(ClockComponent.digitalTime);

  double _minuteProgress;

  set minuteProgress(double minuteProgress) {
    // The layout depends on the time displayed.
    if (_minuteProgress != minuteProgress) markNeedsLayout();

    _minuteProgress = minuteProgress;
  }

  int _hour, _minute;

  set hour(int hour) {
    if (_hour != hour) markNeedsLayout();

    _hour = hour;
  }

  set minute(int minute) {
    if (_minute != minute) markNeedsLayout();

    _minute = minute;
  }

  bool _use24HourFormat;

  set use24HourFormat( use24HourFormat) {
    if (_use24HourFormat != use24HourFormat) markNeedsLayout();

    _use24HourFormat = use24HourFormat;
  }

  Color _textColor;

  set textColor(Color textColor) {
    if (_textColor != textColor) markNeedsPaint();

    _textColor = textColor;
  }

  @override
  void performLayout() {
    size = Size.zero; // todo depends on hour format, hour, minute, and minuteProgress
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // todo

    canvas.restore();
  }
}
