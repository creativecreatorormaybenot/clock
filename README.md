# clock [![demo](https://img.shields.io/badge/view-demo-yellow)](https://creativecreatorormaybenot.github.io/clock) [![article](https://img.shields.io/badge/read-article-blue)](https://link.medium.com/ZBn2ctPvF3) [![video](https://img.shields.io/badge/watch-video-red)](https://youtu.be/E1KIjOsX974) [![Twitter](https://img.shields.io/twitter/follow/creativemaybeno?label=Follow%20me&style=social)](https://twitter.com/creativemaybeno)

[creativecreatorormaybenot](https://github.com/creativecreatorormaybenot)'s playful entry to the [Flutter clock challenge](https://flutter.dev/clock) (is it weird to say it like that?).</a>  
This is a clock display that uses exclusively the Flutter `Canvas` to draw everything you see on screen. That means that there are **no assets**, **no plugins**, and not even prebuilt widgets used, i.e.</a> every `RenderObject` in the tree is custom made by me.

![Quick screen capture showing the final result of the submission](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/showcase.gif)

The code entry point for the clock face is [ `canvas_clock/lib/main.dart` ](https://github.com/creativecreatorormaybenot/clock/blob/master/canvas_clock/lib/main.dart).

## Notes

I was inspired by the design of an old analog barometer and hygrometer kind of device initially and took many design ideas away from that. Later on, many other inspirations came my way :)

You can follow my whole process of building the clock face in this repository, i.e.</a> every bit of it. Maybe it helps someone :)  
Additionally, I wrote a whole article about the technical implementation of my submission.</a> You can [read it here](https://link.medium.com/ZBn2ctPvF3).

### Web version

 * You can view the clock face running on Flutter web [here](https://creativecreatorormaybenot.github.io/clock).

 * *2021 note: this is still the build from Feb 2020, using the Flutter web beta version from Feb 2020. Expect it to not run as well as today's Flutter web apps.*

 * **Notice**: some features are not supported on web, e.g.</a> some of the weather icon animations because trimming paths does not yet work in Flutter web. Same goes for some of the shaders, which are also still *unimplemented*. The sections in code have documentation or comments that link to [Flutter GitHub issues](https://github.com/flutter/flutter/issues) discussing these problems.</a>  

 * Apart from unsupported features, the web version looks slightly different in general because some features of the framework are currently implemented differently in Flutter web.</a> **Ironically**, the radial gradients look *so much sweeter* - you should really see the vibrant dark palette running on Flutter web!

### Implementation

 * No plugins were used at all (check [ `pubspec.yaml` ](https://github.com/creativecreatorormaybenot/clock/blob/master/canvas_clock/pubspec.yaml)). No premade widgets from the framework were used in my own code, i.e.</a> every `RenderObject` in the tree of the clock was custom created by me.</a>

 * Accessibility was implemented customly and it had to because I did not use any prebuilt widgets that come with `Semantics` implementations. Instead I overrode [ `RenderObject.describeSemanticsConfiguration` ](https://api.flutter.dev/flutter/rendering/RenderObject/describeSemanticsConfiguration.html) for every component with semantic relevancy.</a>

 * Last but not least, no assets were used - I think you also get it now (: I wanted to stress it to show what Flutter is capable of.

I did not go with the raw layer (here is an [old demonstration](https://github.com/creativecreatorormaybenot/pong) of the Flutter raw layer I did) nor the rendering layer exclusively.<br>This was not compatible with the `ClockCustomizer` and is also not convenient for working with data at all. The Flutter trees are pretty neat, so we should use them (they make the app reactive) :)

### Hand bouncing

For the animation of the second hand (and minute hand) bouncing of the analog clock, I enjoyed looking at this [slow motion capture of a watch](https://youtu.be/tyl7-gHRBX8?t=29) (the important part is blurry (:, yes).

### Custom fonts

You can view the [ `custom-fonts` branch](https://github.com/creativecreatorormaybenot/clock/tree/custom-fonts) for a version of the clock face with fonts that better match the rest of the design. Watch [a demo of this](https://twitter.com/creativemaybeno/status/1225832214623145985?s=20) (note: this is not part of the design submitted to the Flutter Clock challenge).

## The code

If you want to build the app yourself, make sure to run ***`flutter create .`*** in `canvas_clock` before `flutter run` in order to [generate required directories](https://github.com/creativecreatorormaybenot/clock/issues/1#issuecomment-582123585) first. Note that the repo size is ~100 MB due to the `screen-captures` and `gh-pages` branches. You can [download as ZIP](https://github.com/creativecreatorormaybenot/clock/archive/master.zip), which will only contain the `master` branch without any commits saving a lot of space. If you want to navigate through my process, however, you will need to [clone the repo](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository).

### Understanding the code

As this is a complex project, it will probably be difficult for you to get into the code and understand the structure and reasoning for the parts. This was also the case for [HaMMeReD on Reddit](https://www.reddit.com/r/FlutterDev/comments/ewtqoo/drawing_every_line_pixelperfectly_with_custom/fg88mx5?utm_source=share&utm_medium=web2x). Thanks to them, I have written this [extensive elaboration on the structure and logic behind the project](https://www.reddit.com/r/FlutterDev/comments/ewtqoo/drawing_every_line_pixelperfectly_with_custom/fg9l75a?utm_source=share&utm_medium=web2x). Reading it should give you a good idea of how to navigate the repository and why I chose to do certain things.

### Mistakes in code

Trying to fix some issues, trying to optimize, or just by being human in general, I introduced some bad practices and mistakes into the code on accident that I noticed now after the challenge period has ended.</a>  
I will **not** fix these issues to keep the code how it was when I submitted it - just note that there are things I did not intend to write the way they are and I would have normally fixed :)

## Gallery

See the clock display in all of its glory and some other captures of it below.

![Screenshot of the vibrant light palette](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/vibrant_light.png)

![Screenshot of the vibrant dark palette](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/vibrant_dark_1.png)

![Capture of the assembly of two single frames with vibrant palettes from Skia debugger](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/vibrant_assembly.gif)

![Screenshot of the vibrant dark palette with the ball in the air](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/vibrant_dark_2.png)

![Screenshot of the subtle light palette](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/subtle_light.png)

![Screenshot of the subtle dark palette](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/subtle_dark.png)

![Capture of the assembly of two single frames with subtle palettes from Skia debugger](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/subtle_assembly.gif)

![Screen capture of the clock face with baseline debug paint enabled](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/baselines.gif)

![Screen capture of the clock face showing semantics](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/semantics.gif)

![Screen capture of the clock face with the repaint rainbow enabled](https://github.com/creativecreatorormaybenot/clock/raw/screen-captures/repaint.gif)

## Gratitude

Thanks to [Pants](https://github.com/Pants44) for being awesome and patiently giving me some design feedback, to the Flutter team for creating this challenge and the framework, actively working with the open source community, and providing awesome content like the [Flutter Interact sessions](https://www.youtube.com/playlist?list=PLjxrf2q8roU0o0wKRJTjyN0pSUA6TI8lg), to everyone who shared Flutter Clock progress, which inspired me and helped to keep me motivated, and to all other creators of resources I linked to in the **TODO** section (in this `README.md` file) throughout the development of this entry.

