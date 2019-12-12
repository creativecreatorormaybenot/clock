import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CompositedClock extends MultiChildRenderObjectWidget {
  /// The [children] need to cover each component type in [ClockComponent], which can be specified in the [RenderObject.parentData] using [CompositedClockChildrenParentData].
  /// Every component can only exist exactly once.
  CompositedClock({
    Key key,
    List<Widget> children,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCompositedClock();
  }
}

enum ClockComponent {
  analogTime,
//  digitalTime,
//  temperature,
//  weather,
}

class CompositedClockChildrenParentData
    extends ContainerBoxParentData<RenderBox> {
  ClockComponent component;

  /// Used to mark children that do not set up their [RenderObject.parentData] themselves.
  /// If a child is passed to [CompositedClock] that does not update this to `true`, an error should be thrown.
  bool valid;
}

class RenderCompositedClock extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            CompositedClockChildrenParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            CompositedClockChildrenParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! CompositedClockChildrenParentData) {
      child.parentData = CompositedClockChildrenParentData()..valid = false;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    final components = List.of(ClockComponent.values);

    var child = firstChild;
    while (child != null) {
      final childParentData =
          child.parentData as CompositedClockChildrenParentData;

      if (!childParentData.valid) throw ClockCompositionError(child: child);
      if (!components.contains(childParentData.component)) {
        throw ClockCompositionError(
            message:
                'The children passed to CompositedClock contain the component type ${describeEnum(childParentData.component)} more than once. '
                'Every component can only be passed exactly once.');
      }

      components.remove(childParentData.component);

      switch (childParentData.component) {
        case ClockComponent.analogTime:
          child.layout(const BoxConstraints(), parentUsesSize: true);
          childParentData.offset =
              Offset(size.width / 2 - child.size.width / 2, size.height / 2 - child.size.height / 2);
          break;
      }

      child = childParentData.nextSibling;
    }

    if (components.isNotEmpty) {
      throw ClockCompositionError(
          message:
              'The children passed to CompositedClock do not cover every component in CompositedClockComponent. '
              'You need to pass every component exactly once and specify the component type correctly using CompositedClockChildrenParentData.');
    }
  }

  @override
  void debugPaint(PaintingContext context, Offset offset) {
    assert(() {
      if (debugPaintSizeEnabled) {
        final painter = TextPainter(
            text: const TextSpan(
                text:
                    'Please send me a sign :/ This is leading me nowhere and I do not mean this challenge - creativecreatorormaybenot.',
                style: TextStyle(fontSize: 42, color: Color(0xffff3456))),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
        painter.layout(maxWidth: size.width);
        painter.paint(context.canvas, Offset(0, size.height / 2));
      }
      return true;
    }());
  }
}

class ClockCompositionError extends Error {
  /// A phrase indicating why the error is being thrown. The message is followed by the [stackTrace].
  /// This will not be used if [child] is supplied.
  final String message;

  /// Indicates that the child does not implement [CompositedClockChildrenParentData] correctly.
  final RenderBox child;

  ClockCompositionError({
    this.child,
    this.message,
  }) : assert(child != null || message != null);

  @override
  String toString() =>
      '${message ?? 'A child was passed to CompositedClock which does not set up its RenderObject.parentData '
          'as CompositedClockChildrenParentData correctly (setting CompositedClockChildrenParentData.valid to `true`).'}\n$stackTrace.';
}

/// Takes care of validating [RenderObject]s passed to [CompositedClock] and assigning a [ClockComponent].
/// It also provides easy access to the [CompositedClockChildrenParentData] of this [RenderObject] via [compositedClockData].
class RenderClockPart extends RenderBox {
  final ClockComponent component;

  RenderClockPart(
    this.component,
  ) : assert(component != null);

  CompositedClockChildrenParentData get compositedClockData =>
      parentData as CompositedClockChildrenParentData;

  /// Takes care of validating the RenderObject for when it is passed to [CompositedClock]
  /// and sets [CompositedClockChildrenParentData.component] to the appropriate [ClockComponent].
  /// Thus, this is annotated with [mustCallSuper]. Alternatively, you could ignore this and
  /// implement the validation and setting the component in the sub class, but the whole point of
  /// [RenderClockPart] is to take care of this step, so you should likely extend [RenderBox] instead.
  @override
  @mustCallSuper
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositedClockData.valid = true;
    compositedClockData.component = component;
  }
}
