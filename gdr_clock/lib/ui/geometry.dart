import 'dart:ui';

extension ExtendedOffset on Offset {
  Offset operator +(Size size) => Offset(dx + size.width, dy + size.height);

  /// This exists because of a web compiler error: https://github.com/dart-lang/sdk/issues/39938#issue-542985784
  Offset plus(Size size) => ExtendedOffset(this) + size;

  static Offset max(Offset a, Offset b) => a > b ? a : b;
}

extension ExtendedSize on Size {
  Size get onlyWidth => Size(width, 0);

  Size get onlyHeight => Size(0, height);

  Offset get offset => Offset(width, height);
}

/// Line with functionality tailored to the needs of this clock challenge entry.
class Line {
  final double start, end;

  const Line({this.start, this.end});

  factory Line.fromSE({double start, double extent}) =>
      Line(start: start, end: start + extent);

  factory Line.fromEE({double end, double extent}) =>
      Line(start: end - extent, end: end);

  factory Line.fromSEI({double start, double end, double indent}) =>
      Line(start: start + indent, end: end - indent);

  factory Line.fromCenter({double center, double extent}) =>
      Line(start: center - extent / 2, end: center + extent / 2);

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
