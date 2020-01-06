## TODO

* Use the digital time suffix and otherwise a line that slowly travels from bottom to top to indicate the minute progress.

  + Use https://cubic-bezier.com to design the curve - `Tween` should offer a way to add a curve to it and `TweenSequence` should allow to have two `Tween` s, one for coming up and one from leaving up :)

* Explore [ `TweenSequence` ](https://api.flutter.dev/flutter/animation/TweenSequence-class.html) for the ball movement animation.

* Do not make the ball go off screen.

  + Have a section where the ball slowly rolls onto the slide.

    - In there, there is a little part that is opened right before the ball bounces up and is closed afterwards, so the ball can roll over it.

    - The animation for it should be started every second, similar to how the background animation works - time it takes is the time the `Timer` manages at the moment, which means that the timer will be replaced by this animation controller.

* Take inspiration from https://github.com/JustinFincher/FlutterClock.

* Check https://github.com/gskinnerTeam/flutter_vignettes/tree/master/vignettes/indie_3d for the blending effect.

* Use these colors for a color palette: https://www.dwitter.net/d/5455

  + Ensure that sufficient contrast is present for accessibility reasons.

* Effects/filter ideas:

  + Push some subtle animated transforms (in `CompositedClock` ?) that introduce some nice perspective changes.

    - Potentially rotate whole components because it better shows what the individual parts are :)

  + Add some texture over components, e.g.</a> metal-like, wood-like, or just w/e looks interesting.

* Add animations to every weather conditions.

  + Only animate the current weather condition.

  + Have a looping animation, i.e.</a> every condition has a loop.

  + Use the opportunity to finish/clean off the icons (for now).

    - Make sure that they are all in the same boundaries (draw a debug rect to achieve this).

* Create spin-up animation for when the widget is created or updated? 

  + This could show that the goo actually reacts to the components (even more than the ball push already does).

* Finish all eight themes and ensure that dark mode, light mode, subtle, and vibrant look proper.

  + Choose the best.

* Find out where potentially too many "rebuilds" are triggered, e.g.</a> where `markNeedsLayout` is called unnecessarily or where the layout of a child could actually be determined by the parent and the child does not need to mark the parent as dirty.

  + It seems like `performLayout` and semantics updates of `CompositedClock` are called all the time, even though they would only need to be called when the ball moves (which might be all the time at some point : D).

    - For example, the background animation should not cause all other children to rebuild.

* Potentially consider https://api.flutter.dev/flutter/painting/ShaderWarmUp/warmUpOnCanvas.html and https://api.flutter.dev/flutter/painting/ShaderWarmUp-class.html.

  + Even if performance does not need to be optimized, https://debugger.skia.org/ could be a nice tool to visualize the painting process for the article.

* Make clock available on web via GitHub pages.

  + Watch "Designing for the Web with Flutter" from Flutter Interact for this.

* Check [**7.** "JUDGING"](https://docs.google.com/document/d/1ybyQCK8Sy7vrD9wuc6pbgwVkyrVZ7Rd_41r5NXGqlt8/edit?usp=sharing).

* Format code and follow all other steps decribed [here](https://flutter.dev/clock#submissions).

* Remove unnecessary depencies and other stuff. For example, `pedantic` or `uses-material-design` if there are no icons in the final design.

* Submit submission :)

  + https://flutter.dev/clock - Check rules and FAQ before that.

* Add GIF to README.

* Make repository public.

* Write article about the creation process of the submission on Flutter Community.

  + Ideally go into details regarding the different stages of the process providing images and maybe snapshots by linking to a particular commit on GitHub.

  + Share some of the technical details that make this submission special apart from what can be seen looking at it.

    - For example: what kinds of `RenderObject` s were used and information about `Canvas` and Bézier curves (the simple quadratic and cubic ones `Canvas` offers).

    - Mention that people can, if they are interested in doing custom layouts but `MultiChildRenderObjectWidget` seems too complicated for them, check out https://stackoverflow.com/a/59483482/6509751 to get started with `CustomMultiChildLayout` .

  + The title could be something like "How I made a Flutter Clock Face using only Custom Render Objects", as in no use of prebuilt widgets.

  + Consider embedding some visualizations made by https://debugger.skia.org/.

    - Make sure to replace all `Paint.shader` properties by solid colors when taking the screenshots because the debugger seems to not be able to render shaders (https://stackoverflow.com/q/59589892/6509751).

    - Capture using `flutter screenshot --type=skia --observatory-uri=..` .

  + Mention that usually accessibility and with that semantics are taken care of by prebuilt widgets, but for this clock face it was necessary to do it manually, i.e.</a> override [ `RenderObject.describeSemanticsConfiguration` ](https://api.flutter.dev/flutter/rendering/RenderObject/describeSemanticsConfiguration.html) .

  + Add link to it to README.

  + Potentially post it on https://dev.to/.

  + Share on FlutterDev: Twitter, Reddit, and Discord.

* Share with P.

# clock | [View demo](https://creativecreatorormaybenot.github.io/clock) | [Read article](https://medium.com/flutter-community/)

[creativecreatorormaybenot](https://github.com/creativecreatorormaybenot)'s entry to the [Flutter clock challenge](https://flutter.dev/clock).
I was inspired by the design of an old analog barometer and hygrometer kind of device.

[Quick screen capture showing the final result of the submission]()

The code entry point of the clock face is [ `gdr_clock/lib/main.dart` ](https://github.com/creativecreatorormaybenot/clock/blob/master/gdr_clock/lib/main.dart).

## Notes

* You can follow my whole process of building the clock face in this repository, i.e.</a> every bit of it. Maybe it helps someone :)

### Hand bouncing

* For the animation of the second hand (and minute hand) bouncing of the analog clock, I enjoyed looking at this [slow motion capture of a watch](https://youtu.be/tyl7-gHRBX8?t=29) (the important part is blurry (:, yes).

### Implementation

* No plugins were used at all (check [ `pubspec.yaml` ](https://github.com/creativecreatorormaybenot/clock/blob/master/gdr_clock/pubspec.yaml)).

* No premade widgets from the standard library were used in my own code, i.e.</a> every `RenderObject` in the tree of the clock was custom created by me.

  + Accessibility was implemented customly and it had to because I did not use any prebuilt widgets that come with `Semantics` implementations. Instead I overrode [ `RenderObject.describeSemanticsConfiguration` ](https://api.flutter.dev/flutter/rendering/RenderObject/describeSemanticsConfiguration.html) for every component with semantic relevance.

* No assets were used. The bullet point would be a bit short without this second sentence.

* I did not go with the raw layer (here is an [old demonstration](https://github.com/creativecreatorormaybenot/pong) of the Flutter raw layer I did) nor the rendering layer.<br>This was not compatible with the `ClockCustomizer` and is also not convenient for working with data at all. The Flutter trees are pretty neat, so we should use them (they make the app reactive) :)

