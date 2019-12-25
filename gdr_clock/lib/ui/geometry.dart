import 'dart:ui';

/// Adds shorthand functions.
///
/// Needs a name in order to be accessible from within other files.
extension ExtendedRect on Rect {}

/// Line with functionality tailored to the needs of this clock challenge entry.
class Line {
  final double top, bottom;

  const Line({this.top, this.bottom});

  factory Line.fromTH({double top, double height}) => Line(top: top, bottom: top + height);

  factory Line.fromBH({double bottom, double height}) => Line(top: bottom - height, bottom: bottom);

  factory Line.fromTBI({double top, double bottom, double indent}) => Line(top: top + indent, bottom: bottom - indent);

  double get height => bottom - top;
}
