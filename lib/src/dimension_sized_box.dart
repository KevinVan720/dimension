import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'dimension.dart';

/// Creates a widget that sizes its child to two possible Dimension values
/// If this widget is placed in a infinite constraint environment and either the width
/// or height has percent unit, the constraint is clamped to the size of the screen.
///
/// The screen size used for the viewport units (vw, vh, vmin, vmax) is
/// [MediaQuery.sizeOf] of the [BuildContext].
class DimensionSizedBox extends SingleChildRenderObjectWidget {
  const DimensionSizedBox({
    super.key,
    this.width,
    this.height,
    super.child,
  });

  final Dimension? width;
  final Dimension? height;

  @override
  RenderDimensionSizedBox createRenderObject(BuildContext context) {
    return RenderDimensionSizedBox(
      width: width,
      height: height,
      screenSize: MediaQuery.sizeOf(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderDimensionSizedBox renderObject) {
    renderObject
      ..width = width
      ..height = height
      ..screenSize = MediaQuery.sizeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Dimension>('width', width, defaultValue: null))
      ..add(
          DiagnosticsProperty<Dimension>('height', height, defaultValue: null));
  }
}

class RenderDimensionSizedBox extends RenderProxyBox {
  RenderDimensionSizedBox({
    RenderBox? child,
    Dimension? width,
    Dimension? height,
    required Size screenSize,
  })  : _width = width,
        _height = height,
        _screenSize = screenSize,
        super(child);

  Size get screenSize => _screenSize;
  Size _screenSize;
  set screenSize(Size value) {
    if (_screenSize == value) return;
    _screenSize = value;
    markNeedsLayout();
  }

  /// If non-null, the incoming width to use.
  ///
  /// If non-null, the child is given a tight width constraint that is the px value evaluated by this. If null, the child is given the incoming width constraints.
  Dimension? get width => _width;
  Dimension? _width;
  set width(Dimension? value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  /// If non-null, the incoming height to use.
  ///
  /// If non-null, the child is given a tight height constraint that is the px value evaluated by this. If null, the child is given the incoming height constraints.
  Dimension? get height => _height;
  Dimension? _height;
  set height(Dimension? value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  /// The px value of [width], with percentages relative to [maxWidth] (or to
  /// the screen width if [maxWidth] is infinite), or null if [width] is null.
  double? _resolveWidth(double maxWidth) {
    return _width
        ?.toPX(
            constraint: maxWidth.isFinite ? maxWidth : _screenSize.width,
            screenSize: _screenSize)
        .clamp(0.0, double.maxFinite);
  }

  /// The px value of [height], with percentages relative to [maxHeight] (or
  /// to the screen height if [maxHeight] is infinite), or null if [height] is
  /// null.
  double? _resolveHeight(double maxHeight) {
    return _height
        ?.toPX(
            constraint: maxHeight.isFinite ? maxHeight : _screenSize.height,
            screenSize: _screenSize)
        .clamp(0.0, double.maxFinite);
  }

  BoxConstraints _getInnerConstraints(BoxConstraints constraints) {
    final double? width = _resolveWidth(constraints.maxWidth);
    final double? height = _resolveHeight(constraints.maxHeight);
    return BoxConstraints(
      minWidth: width ?? constraints.minWidth,
      maxWidth: width ?? constraints.maxWidth,
      minHeight: height ?? constraints.minHeight,
      maxHeight: height ?? constraints.maxHeight,
    );
  }

  // The parent constraints are unknown when computing intrinsic dimensions,
  // so percentages are resolved against the screen size, as for an unbounded
  // parent.

  @override
  double computeMinIntrinsicWidth(double height) {
    return _resolveWidth(double.infinity) ??
        super.computeMinIntrinsicWidth(_resolveHeight(height) ?? height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _resolveWidth(double.infinity) ??
        super.computeMaxIntrinsicWidth(_resolveHeight(height) ?? height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _resolveHeight(double.infinity) ??
        super.computeMinIntrinsicHeight(_resolveWidth(width) ?? width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _resolveHeight(double.infinity) ??
        super.computeMaxIntrinsicHeight(_resolveWidth(width) ?? width);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      final Size childSize =
          child!.getDryLayout(_getInnerConstraints(constraints));
      return constraints.constrain(childSize);
    }
    return constraints
        .constrain(_getInnerConstraints(constraints).constrain(Size.zero));
  }

  @override
  double? computeDryBaseline(
      BoxConstraints constraints, TextBaseline baseline) {
    return child?.getDryBaseline(_getInnerConstraints(constraints), baseline);
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(_getInnerConstraints(constraints), parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = constraints
          .constrain(_getInnerConstraints(constraints).constrain(Size.zero));
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Dimension>('width', width, defaultValue: null))
      ..add(
          DiagnosticsProperty<Dimension>('height', height, defaultValue: null))
      ..add(DiagnosticsProperty<Size>('screenSize', screenSize));
  }
}
