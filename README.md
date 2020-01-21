# clock | [View demo](https://creativecreatorormaybenot.github.io/clock) | [Read article](https://medium.com/@creativecreatorormaybenot) (coming soon) | [![Twitter follow](https://img.shields.io/twitter/follow/creativemaybeno?label=Follow%20me&style=social)](https://twitter.com/creativemaybeno)

[creativecreatorormaybenot](https://github.com/creativecreatorormaybenot)'s playful entry to the [Flutter clock challenge](https://flutter.dev/clock) (is it weird to say it like that?).</a>  
This is a clock display that uses exclusively the Flutter `Canvas` to draw everything you see on screen. That means that there are no assets, plugins, and not even prebuilt widgets used, i.e.</a> every `RenderObject` in the tree was custom made by me.

![Quick screen capture showing the final result of the submission](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/showcase.gif)

The code entry point for the clock face is [ `canvas_clock/lib/main.dart` ](https://github.com/creativecreatorormaybenot/clock/blob/master/canvas_clock/lib/main.dart).

## Notes

I was inspired by the design of an old analog barometer and hygrometer kind of device initially and took many design ideas away from that. Later on, many other inspirations came my way :)

You can follow my whole process of building the clock face in this repository, i.e.</a> every bit of it. Maybe it helps someone :)  
Additionally, I wrote a whole article about the technical implementation of my submission.</a> [Read it here](https://medium.com/@creativecreatorormaybenot).

### Web version

* You can view the clock face running on Flutter web [here](https://creativecreatorormaybenot.github.io/clock).

* **Notice**: some features are not supported on web, e.g.</a> some of the weather icon animations because trimming paths does not yet work in Flutter web. Same goes for some of the shaders, which are also still *unimplemented*. The sections in code have documentation or comments that link to [Flutter GitHub issues](https://github.com/flutter/flutter/issues) discussing these problems.

* Apart from unsupported features, the web version looks slightly different in general because some features of the framework are currently implemented differently in Flutter web.

### Implementation

* No plugins were used at all (check [ `pubspec.yaml` ](https://github.com/creativecreatorormaybenot/clock/blob/master/canvas_clock/pubspec.yaml)).

* No premade widgets from the framework were used in my own code, i.e.</a> every `RenderObject` in the tree of the clock was custom created by me.

  + Accessibility was implemented customly and it had to because I did not use any prebuilt widgets that come with `Semantics` implementations. Instead I overrode [ `RenderObject.describeSemanticsConfiguration` ](https://api.flutter.dev/flutter/rendering/RenderObject/describeSemanticsConfiguration.html) for every component with semantic relevance.

* No assets were used. The bullet point would be a bit short without this second sentence.

* I did not go with the raw layer (here is an [old demonstration](https://github.com/creativecreatorormaybenot/pong) of the Flutter raw layer I did) nor the rendering layer.<br>This was not compatible with the `ClockCustomizer` and is also not convenient for working with data at all. The Flutter trees are pretty neat, so we should use them (they make the app reactive) :)

### Hand bouncing

* For the animation of the second hand (and minute hand) bouncing of the analog clock, I enjoyed looking at this [slow motion capture of a watch](https://youtu.be/tyl7-gHRBX8?t=29) (the important part is blurry (:, yes).

## Gallery

See the clock display in all of its glory and some other captures of it below.

![Screenshot of the vibrant light palette](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/vibrant_light.png)

![Screenshot of the vibrant dark palette](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/vibrant_dark_1.png)

![Screenshot of the vibrant dark palette with the ball in the air](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/vibrant_dark_2.png)

![Screenshot of the subtle light palette](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/subtle_light.png)

![Screenshot of the subtle dark palette](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/subtle_dark.png)

![Screen capture of the clock face with baseline debug paint enabled](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/baselines.gif)

![Screen capture of the clock face showing semantics](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/semantics.gif)

![Screen capture of the clock face with the repaint rainbow enabled](https://github.com/creativecreatorormaybenot/clock/raw/master/screen_captures/repaint.gif)

## Gratitude

Thanks to [Pants](https://github.com/Pants44) for being awesome and patiently giving me some design feedback, to the Flutter team for creating this challenge and the framework, actively working with the open source community, and providing awesome content like the [Flutter Interact sessions](https://www.youtube.com/playlist?list=PLjxrf2q8roU0o0wKRJTjyN0pSUA6TI8lg), to everyone who shared Flutter Clock progress, which inspired me and helped to keep me motivated, and to all other creators of resources I linked to in the **TODO** section (in this `README.md` file) throughout the development of this entry.

## TODO

* Record a clip using Skia debugger (https://debugger.skia.org/).

  + Make sure to replace all `Paint.shader` properties by solid colors when taking the screenshots because the debugger seems to not be able to render shaders (https://stackoverflow.com/q/59589892/6509751).

  + `flutter screenshot --type=skia --observatory-uri=..` for the screenshot.

  + Export to GIF.

* Add captures to gallery.

  + Skia debugger GIF.

* Confirm that submission runs on `stable` ([Getting Started, 6.](https://flutter.dev/clock))

* Submit submission :)

  + Format code and follow all other steps decribed [here](https://flutter.dev/clock#submissions).

  + Create the zip by downloading from GitHub (easiest way).

  + Remove some unnecessary stuff from the zip file.

* Add back GitHub topics: `flutter` , `flutter-clock` , & `dart` .

* Add preview image to the repository.

* Create issue for the shadow issue caused by the slide and `CompositedClock._transformedPaint` .

  + Mention the issue in code.

