import 'package:canvas_clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';

/// Hello and welcome to my Flutter Clock submission :)
///
/// I documented the code when I felt like documentation or comments
/// where necessary in order to understand what it does, hence, it
/// should be possible to read through all of the code quite easily
/// (I mean, I have no way to try whether it is easy or not for another
/// person. What I am trying to say is that I tried to explain myself).
/// If you are interested in how this clock works generally, you can
/// take a look at the [`README.md` file](https://github.com/creativecreatorormaybenot/clock/blob/master/README.md),
/// which also contains a link to an article I wrote explaining
/// the structure of this project and the different parts that
/// I used to make it all work.

/// Enables or disables a preset automated customization flow.
///
/// Customization is a good tool for exploring the versatility of this
/// entry by seeing the different states the clock face can be in.
///
/// If you set it to [CustomizationFlow.manual], you can use the
/// default [ClockCustomizer] provided with the challenge, see
/// https://github.com/flutter/flutter_clock/tree/master/flutter_clock_helper.
///
/// If [CustomizationFlow.automatic] is enabled, the clock will run
/// through various [ClockModel] settings automatically.
/// There are timers that predefine when
/// what setting will be adjusted.
/// I used this automated flow to create demo videos of the clock face.
///
/// Changing this requires a hot restart to take the mode into effect.
const customizationFlowMode = CustomizationFlow.automatic;

/// This flag controls whether the [Customizer] will insert a
/// [DebugSemantics].
///
/// Enabling this will visualize the semantic tree of the clock
/// face.
/// It might be interesting to check this out as it will clearly
/// show what parts of the clock have semantic information.
/// If you are using [CustomizationFlow.manual], you will see
/// some semantics annotations from the [ClockCustomizer],
/// which is not part of my submission.
/// Thus, I recommend to use [CustomizationFlow.automatic] when
/// [debugSemantics] is enabled.
///
/// A hot restart is required in order to apply changes to this value.
const debugSemantics = false;

/// The ball will fall down on every [ballEvery]th second, i.e.
/// it is timed in a way that the ball will arrive at its destination
/// exactly then.
///
/// The value must evenly divide 60 (seconds).
///
/// Changing this requires a hot restart to update the animation controllers.
const ballEvery = 60;

/// Sets the palette mode.
///
/// This is a debug constant that will always force a
/// vibrant palette if [PaletteMode.vibrant] is set and
/// force a subtle palette if [PaletteMode.subtle] is set.
///
/// Notice that by default, the color palette
/// is switched every [ballEvery] seconds.
const PaletteMode paletteMode = PaletteMode.adaptive;

void main() {
  runApp(
    // The customizer and palette) are not
    // part of the clock face. They are only used
    // to control its appearance in this demonstration.
    Customizer(
      mode: customizationFlowMode,
      debugSemantics: debugSemantics,
      builder: (context, model) => Palette(
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
  // Because I am using this, I removed the SafeArea
  // widgets in the customizer from the clock helper.
  // It seems that the Android setup created with
  // flutter create . in the stable channel at this
  // time does not support full screen with SafeArea.
  SystemChrome.setEnabledSystemUIOverlays([]);
}
