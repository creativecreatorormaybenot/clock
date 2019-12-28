## TODO

* Add shadow for at least one hand to give a sense of depth.

  + Look at [ `Canvas.drawShadow` ](https://api.flutter.dev/flutter/dart-ui/Canvas/drawShadow.html).

    - See how it handles rotation and if there is a way to make the direction of the light source consistent.

* Use paths for larger clock hands.

  + Use end-of-hand design from GDR clock.

* Add wave animation to background.

* Background curve should be adjusted by the model dynamically, e.g.the height of the cut or w/e and always animate in a relaxing fashion.

* Add ball that bounces about scene, e.g.off the second hand. Maybe only show it sometimes or make it slow and show other balls for special events.

  + This should ideally be relaxing -> not fast.

  + Easy one would be a ball rolling down a Bézier curve every second, calculating the acceleration and velocity of the ball based on the slope of the curve.

    - The curve could slowly change over time like the background does for relaxation.

  + Ball should bounce onto say the analog clock and push it down a bit (analog clock would bounce up again afterwards using elastic out), which would nicely show the gooeyness of the background.

* Push some subtle animated transforms (in CompositedClock?) that introduce some nice perspective changes.

  + Potentially rotate whole components because it better shows what is an individual part :)

* Watch "Design and Build Clock Displays with Flutter" from Flutter Interact again.

* Add animations to every weather conditions.

  + Only animate the current weather condition.

  + Have a looping animation, i.e.every condition has a loop.

* Create spin-up animation for when the widget is created or updated? 

* Checkout two of the vignettes from this [Flutter Interact talk](https://youtu.be/1AxXF038-lY): the one with thousands of particles being animated and the one with the 3D shapes w/ blending magic.

  + Use concepts from there to add that sparkle to the submission.

* Checkout https://twitter.com/Joey_Dunivan/status/1204710943772557312?s=20 and consider doing something like that.

* Handle dark and light modes properly.

* Finish clock first.

* Implement accessibility.

  + Watch "Building in Accessibility with Flutter" from Flutter Interact for this.

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

  + The title could be something like "How I made a Clock Face using only Flutter's built-in rendering layer", as in no use of prebuilt widgets.

  + Consider embedding some visualizations made by https://debugger.skia.org/.

  + Add link to it to README.

  + Share on FlutterDev: Twitter, Reddit, and Discord.

* Share with P.

# clock | [View demo](https://creativecreatorormaybenot.github.io/clock) | [Read article](https://medium.com/flutter-community/)

[creativecreatorormaybenot](https://github.com/creativecreatorormaybenot)'s entry to the [Flutter clock challenge](https://flutter.dev/clock).
I was inspired by the design of an old analog barometer and hygrometer kind of device.

[Quick screen capture showing the final result of the submission]()

## Notes

* You can follow my whole process of building this in this repository. Maybe it helps someone :)

### Hand bouncing

* For the animation of the second hand (and minute hand) bouncing of the analog clock, I enjoyed looking at this [slow motion capture of a watch](https://youtu.be/tyl7-gHRBX8?t=29) (the important part is blurry (:, yes).

### Implementation

* I used only the Flutter rendering layer to create this clock face, i.e.

  no plugins were used at all (check [ `pubspec.yaml` ](https://github.com/creativecreatorormaybenot/clock/blob/master/gdr_clock/pubspec.yaml)).

* No premade widgets from the standard library were used in my own code, i.e. I mostly avoided the widget layer in order to have the most control over the layout.

* No assets were used. The bullet point would be a bit short without this second sentence.

* I did not go with the raw layer (here is an [old demonstration](https://github.com/creativecreatorormaybenot/pong) of the Flutter raw layer I did).

  This was not compatible with the `ClockCustomizer` and is also not convenient for working with data at all. The Flutter trees are pretty neat, so we should use them :)

