/// Adds shorthand functions.
///
/// Needs a name in order to be accessible from within other files.
extension ExtendedNum on num {
  num difference(num other) => (this - other).abs();
}
