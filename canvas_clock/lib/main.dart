import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:canvas_clock/clock.dart';

/// Hello and welcome to my Flutter Clock submission :)
///
/// The palette is a good tool for exploring the
/// versatility of this entry by seeing different color palettes
/// for the clock. Notice that by default, the color palette
/// is switched every [ballEvery] seconds. This is always the case
/// when [forceVibrantPalette] is set to `null`.
/// When `true` the vibrant palette is forced and when `false`
/// the subtle palette.
///
/// You can define your own palette as well by creating a
/// `Map<ClockColor, Color>` and assigning a color for each key.
/// This is the only top-level adjustment because I did not
/// feel the need to expose more as all the components of the clock
/// can easily be modified inside of [Clock], i.e. in the
/// [State.build] method of its state.
///
/// I documented the code when I felt like documentation or comments
/// where necessary in order to understand what it does, hence, it
/// should be possible to read through all of the code quite easily
/// (I mean, I have no way to try whether it is easy or not for another
/// person. What I am trying to say is that I tried to explain myself).
/// If you are interested in how this clock works generally, you can
/// take a look at the [`README.md` file]
/// (https://github.com/creativecreatorormaybenot/clock/blob/master/README.md)
/// , which also contains a link to an article I wrote explaining
/// the structure of this project and the different parts that
/// I used to make it all work.
const bool forceVibrantPalette = null;

/// The ball will fall down on every [ballEvery]th second, i.e.
/// it is timed in a way that the ball will arrive at its destination
/// exactly then.
///
/// Adjusting this value only works partially with a hot reload because
/// the animation controllers are not set up again, which means that
/// you really need a hot restart if you want to change this value.
const ballEvery = 30;

void main() {
  runApp(
    ClockCustomizer(
      (model) => Palette(
        builder: (context, palette) {
          return AnimatedClock(
            model: model,
            palette: palette,
          );
        },
      ),
    ),
  );
  // This makes the app run in full screen mode.
  SystemChrome.setEnabledSystemUIOverlays([]);
}
