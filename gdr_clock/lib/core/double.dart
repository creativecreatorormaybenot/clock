/// Adds shorthand functions.
///
/// Needs a name in order to be accessible from within other files.
extension ExtendedDouble on double {
  double difference(double other) => (this - other).abs();
}
