import 'package:dimension/dimension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Creates a widget that sizes its child to two possible Dimension values
/// If this widget is placed in a infinite constraint environment and either the width
/// or height has percent unit, the constraint is clamped to the size of the screen.

class DimensionSizedBox extends SingleChildRenderObjectWidget {
  const DimensionSizedBox({
    Key? key,
    this.width,
    this.height,
    Widget? child,
  }) : super(key: key, child: child);

  final Dimension? width;
  final Dimension? height;

  @override
  RenderDimensionSizedBox createRenderObject(BuildContext context) {
    return RenderDimensionSizedBox(
      width: width,
      height: height,
      screenSize: MediaQuery.of(context).size,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderDimensionSizedBox renderObject) {
    renderObject
      ..width = width
      ..height = height;
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

  BoxConstraints _getInnerConstraints(BoxConstraints constraints) {
    double minWidth = constraints.minWidth;
    double maxWidth = constraints.maxWidth;
    if (_width != null) {
      final double width = _width!
          .toPX(
              constraint: maxWidth.isFinite ? maxWidth : _screenSize.width,
              screenSize: _screenSize)
          .clamp(0, double.maxFinite);
      minWidth = width;
      maxWidth = width;
    }
    double minHeight = constraints.minHeight;
    double maxHeight = constraints.maxHeight;
    if (_height != null) {
      final double height = _height!
          .toPX(
              constraint: maxHeight.isFinite ? maxHeight : _screenSize.height,
              screenSize: _screenSize)
          .clamp(0.0, double.maxFinite);
      minHeight = height;
      maxHeight = height;
    }
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (_height != null) {
      return _height!
          .toPX(
              constraint: height.isFinite ? height : _screenSize.height,
              screenSize: _screenSize)
          .clamp(0.0, double.maxFinite);
    }
    final double result;
    if (child == null) {
      result = super.computeMinIntrinsicWidth(height);
    } else {
      result = child!.getMinIntrinsicWidth(height);
    }
    assert(result.isFinite);
    return result;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double result;
    if (_height != null) {
      return _height!
          .toPX(
              constraint: height.isFinite ? height : _screenSize.height,
              screenSize: _screenSize)
          .clamp(0.0, double.maxFinite);
    }
    if (child == null) {
      result = super.computeMaxIntrinsicWidth(height);
    } else {
      result = child!.getMaxIntrinsicWidth(height);
    }
    assert(result.isFinite);
    return result;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final double result;
    if (_width != null) {
      return _width!
          .toPX(
              constraint: width.isFinite ? width : _screenSize.width,
              screenSize: _screenSize)
          .clamp(0.0, double.maxFinite);
    }
    if (child == null) {
      result = super.computeMinIntrinsicHeight(width);
    } else {
      result = child!.getMinIntrinsicHeight(width);
    }
    assert(result.isFinite);
    return result;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final double result;
    if (_width != null) {
      return _width!
          .toPX(
              constraint: width.isFinite ? width : _screenSize.width,
              screenSize: _screenSize)
          .clamp(0.0, double.maxFinite);
    }
    if (child == null) {
      result = super.computeMaxIntrinsicHeight(width);
    } else {
      result = child!.getMaxIntrinsicHeight(width);
    }
    assert(result.isFinite);
    return result;
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
  void performLayout() {
    if (child != null) {
      child!.layout(_getInnerConstraints(constraints), parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = constraints
          .constrain(_getInnerConstraints(constraints).constrain(Size.zero));
    }
  }
}
