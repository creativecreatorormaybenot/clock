## TODO

  + Rotate disc instead of hand for weather dial.

    - However, still rotate whole component when the layout animates.

  + Create weather and temperature dials.

  + Get fully familiar with the mock data and design hierarchy to work with the clock data.

  + Add wave animation to background.

  + Background curve should be adjusted by the model dynamically, e.g.the height of the cut or w/e and always animate in a relaxing fashion.

  + Add ball that bounces about scene, e.g.off the second hand. Maybe only show it sometimes or make it slow and show other balls for special events.

    - This should ideally be relaxing -> not fast. 

  + Push some subtle animated transforms (in CompositedClock?) that introduce some nice perspective changes.

  + Watch "Design and Build Clock Displays with Flutter" from Flutter Interact again.

  + Create spin-up animation for when the widget is created or updated? 

  + Checkout two of the vignettes from this [Flutter Interact talk](https://youtu.be/1AxXF038-lY): the one with thousands of particles being animated and the one with the 3D shapes w/ blending magic.

    - Use concepts from there to add that sparkle to the submission.

  + Finish clock first.

  + Implement accessibility.

    - Watch "Building in Accessibility with Flutter" from Flutter Interact for this. 

  + Make clock available on web via GitHub pages.

    - Watch "Designing for the Web with Flutter" from Flutter Interact for this. 

  + Check [**7.** "JUDGING"](https://docs.google.com/document/d/1ybyQCK8Sy7vrD9wuc6pbgwVkyrVZ7Rd_41r5NXGqlt8/edit?usp=sharing).

  + Format code and follow all other steps decribed [here](https://flutter.dev/clock#submissions).

  + Remove unnecessary depencies and other stuff. For example, `pedantic` or `uses-material-design` if there are no icons in the final design.

  + Submit submission :)  

  + Make repository public.

  + Share with P.

# clock

[creativecreatorormaybenot](https://github.com/creativecreatorormaybenot)'s entry to the [Flutter clock challenge](https://flutter.dev/clock).
I was inspired by the design of an old analog barometer and hygrometer kind of device.

## Notes

  + You can follow my whole process of building this in this repository. Maybe it helps someone :)

### Hand bouncing

  + For the animation of the second hand (and minute hand) bouncing of the analog clock, I enjoyed looking at this [slow motion capture of a watch](https://youtu.be/tyl7-gHRBX8?t=29) (the important part is blurry (:, yes).

### Implementation

  + I used only the Flutter rendering layer to create this clock face, i.e.no plugins were used at all (check [ `pubspec.yaml` ](https://github.com/creativecreatorormaybenot/clock/blob/master/gdr_clock/pubspec.yaml)).

  + No widgets from the standard library were used in my own code, i.e. I mostly avoided the widget layer in order to have most control over the layout.

  + No assets were used. The bullet point would be a bit short without this second sentence.

  + I did not go with the raw layer (here is an [old demonstration](https://github.com/creativecreatorormaybenot/pong) of the Flutter raw layer I did). This was not compatible with the `ClockCustomizer` and is also not convenient for working with data at all. The Flutter trees are pretty neat, so we should use them :)

  + Use Bézier curves to display background with cut to another color and animate that nicely, e.g.top half pink and bottom half yellow using a Bézier curve to create the cut.

