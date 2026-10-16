import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'dimension.dart';
import 'dimension_sized_box.dart';

/// Animated version of [DimensionSizedBox] which automatically transitions
/// the [width] and [height] over [duration] whenever they change.
class AnimatedDimensionSizedBox extends ImplicitlyAnimatedWidget {
  const AnimatedDimensionSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
    super.curve,
    required super.duration,
    super.onEnd,
  });

  final Dimension? width;
  final Dimension? height;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  AnimatedWidgetBaseState<AnimatedDimensionSizedBox> createState() =>
      _AnimatedDimensionSizedBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Dimension>('width', width, defaultValue: null))
      ..add(
          DiagnosticsProperty<Dimension>('height', height, defaultValue: null));
  }
}

class _AnimatedDimensionSizedBoxState
    extends AnimatedWidgetBaseState<AnimatedDimensionSizedBox> {
  DimensionTween? _width;
  DimensionTween? _height;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _width = visitor(_width, widget.width,
            (dynamic value) => DimensionTween(begin: value as Dimension?))
        as DimensionTween?;
    _height = visitor(_height, widget.height,
            (dynamic value) => DimensionTween(begin: value as Dimension?))
        as DimensionTween?;
  }

  @override
  Widget build(BuildContext context) {
    return DimensionSizedBox(
      width: _width?.evaluate(animation),
      height: _height?.evaluate(animation),
      child: widget.child,
    );
  }
}
