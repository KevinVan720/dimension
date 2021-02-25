import 'package:flutter/material.dart';
import 'package:flutter_class_parser/to_json.dart';

import 'dimension.dart';

class DynamicEdgeInsets {
  final Dimension? top;
  final Dimension? bottom;
  final Dimension? left;
  final Dimension? right;

  const DynamicEdgeInsets.all(Dimension value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  const DynamicEdgeInsets.only({
    this.left = const Length(0.0),
    this.top = const Length(0.0),
    this.right = const Length(0.0),
    this.bottom = const Length(0.0),
  });

  const DynamicEdgeInsets.symmetric({
    Dimension vertical = const Length(0.0),
    Dimension horizontal = const Length(0.0),
  })  : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst.updateNotNull("top", top?.toJson());
    rst.updateNotNull("bottom", bottom?.toJson());
    rst.updateNotNull("left", left?.toJson());
    rst.updateNotNull("right", right?.toJson());
    return rst;
  }

  DynamicEdgeInsets copyWith({
    Dimension? top,
    Dimension? bottom,
    Dimension? left,
    Dimension? right,
  }) {
    return DynamicEdgeInsets.only(
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
      right: right ?? this.right,
    );
  }

  EdgeInsets toEdgeInsets(
      {required Size constraintSize, required Size screenSize}) {
    double top = this
            .top
            ?.toPX(constraint: constraintSize.height, screenSize: screenSize) ??
        0.0;
    double bottom = this
            .bottom
            ?.toPX(constraint: constraintSize.height, screenSize: screenSize) ??
        0.0;
    double left = this
            .left
            ?.toPX(constraint: constraintSize.width, screenSize: screenSize) ??
        0.0;
    double right = this
            .right
            ?.toPX(constraint: constraintSize.width, screenSize: screenSize) ??
        0.0;
    return EdgeInsets.only(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
    );
  }
}
