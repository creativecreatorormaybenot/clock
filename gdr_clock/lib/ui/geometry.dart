import 'dart:ui';

/// Adds shorthand functions.
///
/// Needs a name in order to be accessible from within other files.
extension ExtendedRect on Rect {}

/// Line with functionality tailored to the needs of this clock challenge entry.
class Line {
  final double start, end;

  const Line({this.start, this.end});

  factory Line.fromSE({double start, double extent}) => Line(start: start, end: start + extent);

  factory Line.fromEE({double end, double extent}) => Line(start: end - extent, end: end);

  factory Line.fromSEI({double start, double end, double indent}) => Line(start: start + indent, end: end - indent);

  double get extent => end - start;

  /// Takes [start] as either [dx] or [dy] based on what is not supplied to construct an offset.
  /// This means that [start] is the top of a line in one case and the left in the other.
  Offset startOffset({double dx, double dy}) {
    assert(dx == null || dy == null);

    if (dx == null) return Offset(start, dy);
    return Offset(dx, start);
  }

  /// Takes [start] as either [dx] or [dy] based on what is not supplied to construct an offset.
  /// This means that [end] is the bottom of a line in one case and the right in the other.
  Offset endOffset({double dx, double dy}) {
    assert(dx == null || dy == null);

    if (dx == null) return Offset(end, dy);
    return Offset(dx, end);
  }
}
