import 'dart:ui';

/// Adds shorthand functions.
///
/// Needs a name in order to be accessible from within other file.
extension AdvancedRect on Rect {
  Rect expandToIncludePoint(Offset point) => expandToInclude(Rect.fromCenter(center: point, width: 0, height: 0));
}
