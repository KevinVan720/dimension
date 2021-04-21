import 'package:dimension/dimension.dart';
import 'package:flutter/material.dart';

class AnimatedDimensionSizedBox extends ImplicitlyAnimatedWidget {
  AnimatedDimensionSizedBox({
    Key? key,
    this.width,
    this.height,
    this.child,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  final Dimension? width;
  final Dimension? height;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.src.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  _AnimatedDimensionSizedBoxState createState() =>
      _AnimatedDimensionSizedBoxState();
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
      child: widget.child,
      width: _width?.evaluate(animation),
      height: _height?.evaluate(animation),
    );
  }
}
