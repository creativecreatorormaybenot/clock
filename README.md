## TODO

 * Implement minute hand and make minute and second hand both bounce.

 * Get fully familiar with the mock data and design hierarchy to work with the clock data.

 * Finish clock first.

 * Implement accessibility.

 * Make clock available on web via GitHub pages.

 * Check [**7.** "JUDGING"](https://docs.google.com/document/d/1ybyQCK8Sy7vrD9wuc6pbgwVkyrVZ7Rd_41r5NXGqlt8/edit?usp=sharing).

 * Format code and follow all other steps decribed [here](https://flutter.dev/clock#submissions).

 * Remove unnecessary depencies and other stuff. For example, `pedantic` or `uses-material-design` if there are no icons in the final design.

 * Submit submission :)

 * Make repository public.

# clock

[creativecreatorormaybenot](https://github.com/creativecreatorormaybenot)'s entry to the [Flutter clock challenge](https://flutter.dev/clock).  
I was inspired by the design of an old analog barometer and hygrometer kind of device.

## Implementation

 * I used only the Flutter rendering layer to create this clock face, i.e. no plugins were used at all (check [`pubspec.yaml`](https://github.com/creativecreatorormaybenot/clock/blob/master/gdr_clock/pubspec.yaml)).

 * No widgets from the standard library were used in my own code, i.e. I basically avoided the widget layer completely in order to have most control over the layout.

 * No assets were used. The bullet point would be a bit short without this second sentence.

 * I did not go with the raw layer (here is an [old demonstration](https://github.com/creativecreatorormaybenot/pong) of the Flutter raw layer I did). This was not compatible with the `ClockCustomizer` and is also not convenient for working with data at all. The Flutter trees are pretty neat, so we should use them :)

## Notes

 * You can follow my whole process of building this in this repository. Maybe it helps someone :)