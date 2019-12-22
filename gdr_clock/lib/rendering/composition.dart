import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [C] is intended to be an enum that indicates which child this parent data belongs to.
class CompositionChildrenParentData<C> extends ContainerBoxParentData<RenderBox> {
  C childType;

  /// Used to mark children that do not set up their [RenderObject.parentData] themselves.
  /// If a child is passed to [CompositedClock] that does not update this to `true`, an error should be thrown.
  bool valid;
}

/// [RenderObject] for [MultiChildRenderObjectWidget]s that are supposed to layout a specific set of children and all of these only exactly once.
///
/// [C] is intended to be an enum.
abstract class RenderComposition<C, D extends CompositionChildrenParentData<C>, P extends MultiChildRenderObjectWidget> extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, D>, RenderBoxContainerDefaultsMixin<RenderBox, D> {
  /// All the enum entries for [C] should be passed as [children]. This can be achieved by using `enum.values`.
  final List<C> children;

  RenderComposition(this.children);

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  Map<C, RenderBox> layoutChildren;
  Map<C, D> layoutParentData;

  /// Sets up [layoutChildren] and [layoutParentData], so this should be called at the start of [performLayout] in subclasses.
  @override
  @mustCallSuper
  void performLayout() {
    layoutChildren = <C, RenderBox>{};
    layoutParentData = <C, D>{};

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as D, type = childParentData.childType;

      if (!childParentData.valid) throw CompositionError<P, D>(child: child);
      if (layoutChildren.containsKey(type)) {
        throw CompositionError<P, D>(
            message: 'The children passed to $P contain the child type ${describeEnum(type)} more than once. '
                'Every child type can only be passed exactly once.');
      }

      layoutChildren[type] = child;
      layoutParentData[type] = childParentData;

      child = childParentData.nextSibling;
    }

    final missingComponents = children.where((child) => !layoutChildren.containsKey(child));

    if (missingComponents.isNotEmpty) {
      throw CompositionError<P, D>(
          message: 'The children passed to $P do not cover every child type of $children. '
              'You need to pass every child type exactly once and specify the child type correctly using $CompositionChildrenParentData.\n'
              'Missing children are $missingComponents.');
    }

    // This should prevent accidental use of child.
    child = null;
    //</editor-fold>
  }

  Function(C child) paintChild;

  /// Sets up [paintChild] for all children. Hence, this should be called at the start of the [paint] function of subclasses.
  @override
  @mustCallSuper
  void paint(PaintingContext context, Offset offset) {
    final children = <C, RenderBox>{}, parentData = <C, D>{};

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as D, component = childParentData.childType;

      children[component] = child;
      parentData[component] = childParentData;

      child = childParentData.nextSibling;
    }

    paintChild = (C child) => context.paintChild(children[child], parentData[child].offset + offset);
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

/// Takes care of validating [RenderObject]s passed to [RenderComposition] and assigning an enum value of type [C].
/// It also provides easy access to the [CompositionChildrenParentData] of this [RenderObject] via [compositionData].
abstract class RenderCompositionChild<C, D extends CompositionChildrenParentData<C>> extends RenderBox {
  final C childType;

  RenderCompositionChild(
    this.childType,
  ) : assert(childType != null);

  D get compositionData => parentData as D;

  /// Takes care of validating the RenderObject for when it is passed to [CompositedClock]
  /// and sets [ClockChildrenParentData.childType] to the appropriate [ClockComponent].
  /// Thus, this is annotated with [mustCallSuper]. Alternatively, you could ignore this and
  /// implement the validation and setting the component in the sub class, but the whole point of
  /// [RenderClockComponent] is to take care of this step, so you should likely extend [RenderBox] instead.
  @override
  @mustCallSuper
  void attach(PipelineOwner owner) {
    super.attach(owner);

    compositionData
      ..valid = true
      ..childType = childType;
  }
}

class CompositionError<P extends MultiChildRenderObjectWidget, D extends CompositionChildrenParentData> extends Error {
  /// A phrase indicating why the error is being thrown. The message is followed by the [stackTrace].
  /// This will not be used if [child] is supplied.
  final String message;

  /// Indicates that the child does not implement [ClockChildrenParentData] correctly.
  final RenderBox child;

  CompositionError({
    this.child,
    this.message,
  }) : assert(child != null || message != null);

  @override
  String toString() => '${message ?? 'A child ($child) was passed to $P which does not set up its $RenderObject.parentData '
      'as $D correctly (setting $D.valid to `true`).'}\n$stackTrace.';
}
