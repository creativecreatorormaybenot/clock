import 'dart:ui';

import 'package:vector_math/vector_math_64.dart' show Vector2;

extension ExtendedVector2 on Vector2 {
  Offset get offset => Offset(x, y);
}
