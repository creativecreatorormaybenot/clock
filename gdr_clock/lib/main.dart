import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:gdr_clock/clock.dart';

/// Hello and welcome to my Flutter Clock submission :)
///
/// Adjusting [useVibrantPalette] is a quick way to explore the
/// versatility of this entry by seeing different color palettes
/// for the clock.
/// You can define your own palette as well by creating a
/// `Map<ClockColor, Color>` and assigning a color for each key.
/// This is the only top-level adjustment because I did not
/// feel the need to expose more as all the components of the clock
/// can easily be modified inside of [Clock], i.e. in the
/// [State.build] method of its state.
///
/// I documented the code when I felt like documentation or comments
/// where necessary in order to understand what it does, hence, it
/// should be possible to read through all of the code quite easily.
/// If you are interested in how this clock works generally, you can
/// take a look at the [`README.md` file]
/// (https://github.com/creativecreatorormaybenot/clock/blob/master/README.md)
/// , which also contains a link to an article I wrote explaining
/// the structure of this project and the different parts that
/// I used to make it all work.
const useVibrantPalette = true;

void main() {
  runApp(
    ClockCustomizer(
      (model) => Builder(
        builder: (context) {
          return Clock(
            model: model,
            palette: resolvePalette(context),
          );
        },
      ),
    ),
  );
}
