extension ExtendedInt on int {
  String get twoDigitTime => '$this'.padLeft(2, '0');
}
