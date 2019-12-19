import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [C] is intended to be an enum that indicates which child this parent data belongs to.
class CompositionChildrenParentData<C> extends ContainerBoxParentData<RenderBox> {
  C child;

  /// Used to mark children that do not set up their [RenderObject.parentData] themselves.
  /// If a child is passed to [CompositedClock] that does not update this to `true`, an error should be thrown.
  bool valid;
}

/// [C] is intended to be an enum.
abstract class RenderComposition<C, D extends CompositionChildrenParentData> extends RenderBox with ContainerRenderObjectMixin<RenderBox, D>, RenderBoxContainerDefaultsMixin<RenderBox, D> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! D) {
      child.parentData = (CompositionChildrenParentData() as D)..valid = false;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  Map<C, RenderBox> _layoutChildren;
  Map<C, D> _layoutParentData;

  /// Sets up [_layoutChildren] and [_layoutParentData], so this should be called at the start of [performLayout] in subclasses.
  @override
  @mustCallSuper
  void performLayout() {
    final children = <ClockComponent, RenderBox>{}, parentData = <ClockComponent, CompositedClockChildrenParentData>{};

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as CompositedClockChildrenParentData, component = childParentData.child;

      if (!childParentData.valid) throw CompositionError(child: child);
      if (children.containsKey(component)) {
        throw CompositionError(
            message: 'The children passed to CompositedClock contain the component type ${describeEnum(component)} more than once. '
                'Every component can only be passed exactly once.');
      }

      children[component] = child;
      parentData[component] = childParentData;

      child = childParentData.nextSibling;
    }

    final missingComponents = ClockComponent.values.where((component) => !children.containsKey(component));

    if (missingComponents.isNotEmpty) {
      throw CompositionError(
          message: 'The children passed to CompositedClock do not cover every component of ${ClockComponent.values}. '
              'You need to pass every component exactly once and specify the component type correctly using CompositedClockChildrenParentData.\n'
              'Missing components are $missingComponents.');
    }

    // This should prevent accidental use of child.
    child = null;
    //</editor-fold>
  }

  Function(D child) paintChild;

  /// Sets up [paintChild] for all children. Hence, this should be called at the start of the [paint] function of subclasses.
  @override
  @mustCallSuper
  void paint(PaintingContext context, Offset offset) {
    final children = <C, RenderBox>{}, parentData = <C, D>{};

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as D, component = childParentData.child;

      children[component] = child;
      parentData[component] = childParentData;

      child = childParentData.nextSibling;
    }

    paintChild = (D child) => context.paintChild(children[child], parentData[child].offset + offset);
  }

  @override
  @mustCallSuper
  void debugPaint(PaintingContext context, Offset offset) {
    assert(() {
      if (debugPaintSizeEnabled) {
        final painter = TextPainter(
            text: const TextSpan(
                text: 'Please send me a sign :/ This is leading me nowhere and I do not mean this challenge - creativecreatorormaybenot.',
                style: TextStyle(fontSize: 42, color: Color(0xffff3456), backgroundColor: Color(0xffffffff))),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
        painter.layout(maxWidth: size.width);
        painter.paint(context.canvas, Offset(0, size.height / 2));
      }
      return true;
    }());
  }
}

/// Takes care of validating [RenderObject]s passed to [CompositedClock] and assigning a [ClockComponent].
/// It also provides easy access to the [CompositedClockChildrenParentData] of this [RenderObject] via [compositedClockData].
abstract class RenderCompositionChild extends RenderBox { // todo
  final ClockComponent component;

  RenderClockComponent(
      this.component,
      ) : assert(component != null);

  CompositedClockChildrenParentData get compositedClockData =>
      parentData as CompositedClockChildrenParentData;

  /// Takes care of validating the RenderObject for when it is passed to [CompositedClock]
  /// and sets [CompositedClockChildrenParentData.child] to the appropriate [ClockComponent].
  /// Thus, this is annotated with [mustCallSuper]. Alternatively, you could ignore this and
  /// implement the validation and setting the component in the sub class, but the whole point of
  /// [RenderClockComponent] is to take care of this step, so you should likely extend [RenderBox] instead.
  @override
  @mustCallSuper
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositedClockData.valid = true;
    compositedClockData.child = component;
  }
}

class CompositionError<P extends MultiChildRenderObjectWidget, D extends ContainerBoxParentData> extends Error {
  /// A phrase indicating why the error is being thrown. The message is followed by the [stackTrace].
  /// This will not be used if [child] is supplied.
  final String message;

  /// Indicates that the child does not implement [CompositedClockChildrenParentData] correctly.
  final RenderBox child;

  CompositionError({
    this.child,
    this.message,
  }) : assert(child != null || message != null);

  @override
  String toString() => '${message ?? 'A child was passed to $P which does not set up its $RenderObject.parentData '
      'as $D correctly (setting $D.valid to `true`).'}\n$stackTrace.';
}
