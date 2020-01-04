## TODO

* Mark the places when the ball drops on the analog clock with little icons, i.e.</a> more towards the center than the numbers and tick marks.

* Watch "Design and Build Clock Displays with Flutter" from Flutter Interact again.

  + https://youtu.be/i60HG1TtKJo

* Checkout two of the vignettes from this [Flutter Interact talk](https://youtu.be/1AxXF038-lY): the one with thousands of particles being animated and the one with the 3D shapes w/ blending magic.

  + Use concepts from there to add that sparkle to the submission.

* Check these for inspiration:

  + https://twitter.com/jgrandchavin/status/1213072263236476929

  + https://twitter.com/HanielBaez/status/1212911845457252352

  + https://twitter.com/berger_apps/status/1210119759251066880

  + https://twitter.com/Joey_Dunivan/status/1204710943772557312

* Add digital clock.

* Do not make the ball go off screen.

  + Have a section where the ball slowly rolls onto the slide.

    - In there, there is a little part that is opened right before the ball bounces up and is closed afterwards, so the ball can roll over it.

    - The animation for it should be started every second, similar to how the background animation works - time it takes is the time the `Timer` manages at the moment, which means that the timer will be replaced by this animation controller.

* Implement accessibility.

  + Watch "Building in Accessibility with Flutter" from Flutter Interact for this.

* Use these colors for a color palette: https://www.dwitter.net/d/5455

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

* Potentially consider https://api.flutter.dev/flutter/painting/ShaderWarmUp/warmUpOnCanvas.html and https://api.flutter.dev/flutter/painting/ShaderWarmUp-class.html.

  + Even if performance does not need to be optimized, https://debugger.skia.org/ could be a nice tool to visualize the painting process for the article.

* Make clock available on web via GitHub pages.

  + Watch "Designing for the Web with Flutter" from Flutter Interact for this.

* Check [**7.** "JUDGING"](https://docs.google.com/document/d/1ybyQCK8Sy7vrD9wuc6pbgwVkyrVZ7Rd_41r5NXGqlt8/edit?usp=sharing).

* Format code and follow all other steps decribed [here](https://flutter.dev/clock#submissions).

* Remove unnecessary depencies and other stuff. For example, `pedantic` or `uses-material-design` if there are no icons in the final design.

* Submit submission :)

* Add GIF to README.

* Make repository public.

* Write article about the creation process of the submission on Flutter Community.

  + Ideally go into details regarding the different stages of the process providing images and maybe snapshots by linking to a particular commit on GitHub.

  + Share some of the technical details that make this submission special apart from what can be seen looking at it.

    - For example: what kinds of `RenderObject` s were used and information about `Canvas` and Bézier curves (the simple quadratic and cubic ones `Canvas` offers).

    - Mention that people can, if they are interested in doing custom layouts but `MultiChildRenderObjectWidget` seems too complicated for them, check out https://stackoverflow.com/a/59483482/6509751 to get started with `CustomMultiChildLayout` .

  + The title could be something like "How I made a Flutter Clock Face using only Custom Render Objects", as in no use of prebuilt widgets.

  + Consider embedding some visualizations made by https://debugger.skia.org/.

  + Add link to it to README.

  + Share on FlutterDev: Twitter, Reddit, and Discord.

* Share with P.

# clock | [View demo](https://creativecreatorormaybenot.github.io/clock) | [Read article](https://medium.com/flutter-community/)

[creativecreatorormaybenot](https://github.com/creativecreatorormaybenot)'s entry to the [Flutter clock challenge](https://flutter.dev/clock).
I was inspired by the design of an old analog barometer and hygrometer kind of device.

[Quick screen capture showing the final result of the submission]()

The code entry point of the clock face is [ `gdr_clock/lib/main.dart` ](https://github.com/creativecreatorormaybenot/clock/blob/master/gdr_clock/lib/main.dart).

## Notes

* You can follow my whole process of building this in this repository. Maybe it helps someone :)

### Hand bouncing

* For the animation of the second hand (and minute hand) bouncing of the analog clock, I enjoyed looking at this [slow motion capture of a watch](https://youtu.be/tyl7-gHRBX8?t=29) (the important part is blurry (:, yes).

### Implementation

* No plugins were used at all (check [ `pubspec.yaml` ](https://github.com/creativecreatorormaybenot/clock/blob/master/gdr_clock/pubspec.yaml)).

* No premade widgets from the standard library were used in my own code, i.e.</a> every `RenderObject` in the tree of the clock was custom created by me.

* No assets were used. The bullet point would be a bit short without this second sentence.

* I did not go with the raw layer (here is an [old demonstration](https://github.com/creativecreatorormaybenot/pong) of the Flutter raw layer I did) nor the rendering layer.<br>This was not compatible with the `ClockCustomizer` and is also not convenient for working with data at all. The Flutter trees are pretty neat, so we should use them (they make the app reactive) :)

