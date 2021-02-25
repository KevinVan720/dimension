import 'package:flutter/material.dart';
import 'dimension.dart';

class DynamicOffset {
  /// Constructs an elliptical radius with the given radii.
  const DynamicOffset(this.dx, this.dy);

  //DynamicOffset.fromJson(Map<String, dynamic> map): dx=Length.fromJson(map["dx"]), dy=Length.fromJson(map["dy"]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map["dx"] = dx.toJson();
    map["dy"] = dy.toJson();
    return map;
  }

  static const DynamicOffset zero =
      DynamicOffset(const Length(0), const Length(0));

  /// The radius value on the horizontal axis.
  final Dimension dx;

  /// The radius value on the vertical axis.
  final Dimension dy;

  DynamicOffset copyWith({
    Dimension? dx,
    Dimension? dy,
  }) {
    return DynamicOffset(
      dx ?? this.dx,
      dy ?? this.dy,
    );
  }

  Offset toOffset({Size? size, Size? screenSize}) {
    return Offset(dx.toPX(constraint: size?.width, screenSize: screenSize),
        dy.toPX(constraint: size?.height, screenSize: screenSize));
  }

  @override
  int get hashCode => hashValues(dx, dy);

  @override
  bool operator ==(dynamic other) {
    return other is DynamicOffset && dx == other.dx && dy == other.dy;
  }
}
