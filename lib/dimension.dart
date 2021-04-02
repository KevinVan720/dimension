library dimension;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'convert_utils.dart';
import 'parse_json.dart';

export 'convert_utils.dart';
export 'dynamic_edge_insets.dart';
export 'dynamic_offset.dart';
export 'parse_json.dart';

///Base class of Dimension. Convert to actual px value by calling
///the toPX function.
abstract class Dimension {
  const Dimension();

  dynamic toJson();

  double toPX({double? constraint, Size? screenSize});

  @protected
  Dimension? add(Dimension other) => null;

  Dimension operator +(Dimension other) {
    return add(other) ??
        other.add(this) ??
        _CompoundDimension(<Dimension>[other, this]);
  }

  Dimension operator -();

  Dimension operator -(Dimension other) {
    return add(-other) ??
        (-other).add(this) ??
        _CompoundDimension(<Dimension>[-other, this]);
  }

  Dimension scale(double t);

  ///does not depend on parent dimension (no % unit)
  bool get isAbsolute => true;

  ///does not depend on viewport size (no VH,VW,VMIN,VMAX unit)
  bool get isLocal => true;

  static Dimension max(Dimension value1, Dimension value2) {
    return _MaxDimension(value1: value1, value2: value2);
  }

  static Dimension min(Dimension value1, Dimension value2) {
    return _MinDimension(value1: value1, value2: value2);
  }

  static Dimension clamp(Dimension min, Dimension value, Dimension max) {
    return _MaxDimension(
        value1: min, value2: _MinDimension(value1: value, value2: max));
  }

  @protected
  Dimension? lerpFrom(Dimension? a, double t) {
    if (a == null) return scale(t);
    return null;
  }

  @protected
  Dimension? lerpTo(Dimension? b, double t) {
    if (b == null) return scale(1.0 - t);
    return null;
  }

  static Dimension? lerp(Dimension? a, Dimension? b, double t) {
    Dimension? result;
    if (b != null) result = b.lerpFrom(a, t);
    if (result == null && a != null) result = a.lerpTo(b, t);
    return result ?? (t < 0.5 ? a : b);
  }
}

enum LengthUnit {
  ///logic pixel
  px,

  ///percent of the parent size
  percent,

  ///percent of the screen width
  vw,

  ///percent of the screen height
  vh,

  ///percent of the screen shortest side
  vmin,

  ///percent of the screen longest side
  vmax,

  ///Aspect Ratio?
  //ar,

  ///no constraint
  //auto,

}

const Map<String, LengthUnit> lengthUnitMap = {
  "\%": LengthUnit.percent,
  "px": LengthUnit.px,
  "vh": LengthUnit.vh,
  "vw": LengthUnit.vw,
  "vmin": LengthUnit.vmin,
  "vmax": LengthUnit.vmax,
};

LengthUnit? parseLengthUnit(String? unit) {
  if (unit == null || unit.trim().length == 0) {
    return null;
  }
  return lengthUnitMap[unit];
}

///This is the one actually used by users.
///Contains a value and a unit
class Length extends Dimension {
  final double value;
  final LengthUnit unit;

  const Length(this.value, {this.unit = LengthUnit.px});

  static Length? fromJson(String? string) {
    if (string == null) return null;
    final RegExp regExp = RegExp('[a-zA-Z\%]');
    int index = string.indexOf(regExp);
    if (index != -1) {
      return Length(double.tryParse(string.substring(0, index)) ?? 0,
          unit: parseLengthUnit(string.substring(index)) ?? LengthUnit.px);
    } else {
      return Length(0);
    }
  }

  String getUnit() {
    if (unit == LengthUnit.percent) return "%";
    return unit.toString().substring(11);
  }

  String toJson() {
    return value.toString() + getUnit();
  }

  Length scale(double t) {
    return Length(value * t, unit: unit);
  }

  @override
  bool get isAbsolute => unit != LengthUnit.percent;

  @override
  bool get isLocal =>
      unit != LengthUnit.vh &&
      unit != LengthUnit.vw &&
      unit != LengthUnit.vmin &&
      unit != LengthUnit.vmax;

  @override
  Dimension? lerpFrom(Dimension? a, double t) {
    if (a == null) return scale(t);
    List<Dimension> lengths =
        _CompoundDimension.combineLength([a.scale(1 - t), this.scale(t)]);
    if (lengths.length == 1) return lengths.first;
    return _CompoundDimension(lengths);
  }

  @override
  Dimension? lerpTo(Dimension? b, double t) {
    if (b == null) return scale(1.0 - t);
    List<Dimension> lengths =
        _CompoundDimension.combineLength([this.scale(1 - t), b.scale(t)]);
    if (lengths.length == 1) return lengths.first;
    return _CompoundDimension(lengths);
  }

  double toPX({double? constraint, Size? screenSize}) {
    switch (unit) {
      case LengthUnit.px:
        return value;
      case LengthUnit.percent:
        return value / 100.0 * (constraint ?? 100.0);
      case LengthUnit.vw:
        return value / 100.0 * (screenSize?.width ?? 100.0);
      case LengthUnit.vh:
        return value / 100.0 * (screenSize?.height ?? 100.0);
      case LengthUnit.vmin:
        return value / 100.0 * (screenSize?.shortestSide ?? 100.0);
      case LengthUnit.vmax:
        return value / 100.0 * (screenSize?.longestSide ?? 100.0);
      default:
        return 0;
    }
  }

  Length copyWith({
    double? value,
    LengthUnit? unit,
  }) {
    return Length(
      value ?? this.value,
      unit: unit ?? this.unit,
    );
  }

  static double? fromPX(double? px, LengthUnit unit,
      {double? constraint, Size? screenSize}) {
    if (px == null) return null;
    switch (unit) {
      case LengthUnit.px:
        return px;
      case LengthUnit.percent:
        return px / (constraint ?? 100.0) * 100.0;
      case LengthUnit.vw:
        return px / (screenSize?.width ?? 100.0) * 100.0;
      case LengthUnit.vh:
        return px / (screenSize?.height ?? 100.0) * 100.0;
      case LengthUnit.vmin:
        return px / (screenSize?.shortestSide ?? 100.0) * 100.0;
      case LengthUnit.vmax:
        return px / (screenSize?.longestSide ?? 100.0) * 100.0;
    }
  }

  Length operator -() => this.copyWith(value: -this.value);

  @override
  int get hashCode => hashValues(value, unit);

  @override
  bool operator ==(dynamic other) {
    return other is Length && value == other.value && unit == other.unit;
  }

  @override
  String toString() {
    switch (unit) {
      case LengthUnit.px:
        return value.roundWithPrecision(1).toString() + "px";
      case LengthUnit.percent:
        return value.roundWithPrecision(1).toString() + "%";
      case LengthUnit.vw:
        return value.roundWithPrecision(1).toString() + "%vw";
      case LengthUnit.vh:
        return value.roundWithPrecision(1).toString() + "%vh";
      case LengthUnit.vmin:
        return value.roundWithPrecision(1).toString() + "%vmin";
      case LengthUnit.vmax:
        return value.roundWithPrecision(1).toString() + "%vmax";
      default:
        return "";
    }
  }
}

///compound dimension, basically a list of dimension values
class _CompoundDimension extends Dimension {
  final List<Dimension> lengths;
  _CompoundDimension(this.lengths) : assert(lengths.length >= 2);

  List<dynamic> toJson() {
    return lengths.map((e) => e.toJson()).toList();
  }

  _CompoundDimension scale(double t) {
    return _CompoundDimension(lengths.map((e) => e.scale(t)).toList());
  }

  @override
  bool get isAbsolute => lengths.every((element) => element.isAbsolute);

  @override
  bool get isLocal => lengths.every((element) => element.isLocal);

  static List<Dimension> combineLength(List<Dimension> list) {
    List<Dimension> rst = [];
    list.forEach((element) {
      if (element is Length) {
        int index =
            rst.indexWhere((e) => e is Length && e.unit == element.unit);
        if (index != -1) {
          rst[index] = Length((rst[index] as Length).value + element.value,
              unit: element.unit);
        } else {
          rst.add(element);
        }
      } else {
        rst.add(element);
      }
    });
    return rst;
  }

  @override
  Dimension? add(Dimension other) {
    List<Dimension> merged = lengths;
    if (other is! _CompoundDimension) {
      merged.add(other);
    } else {
      merged.addAll(other.lengths);
    }

    return _CompoundDimension(combineLength(merged));
  }

  Dimension operator -() {
    return _CompoundDimension(lengths.map((e) => -e).toList());
  }

  @override
  Dimension? lerpFrom(Dimension? a, double t) {
    return _CompoundDimension.lerp(a, this, t);
  }

  @override
  Dimension? lerpTo(Dimension? b, double t) {
    return _CompoundDimension.lerp(this, b, t);
  }

  static _CompoundDimension lerp(Dimension? a, Dimension? b, double t) {
    final List<Dimension> results = <Dimension>[];

    if (a != null) {
      if (a is! _CompoundDimension) {
        results.add(a.scale(1.0 - t));
      } else {
        results.addAll(a.scale(1.0 - t).lengths);
      }
    }

    if (b != null) {
      if (b is! _CompoundDimension) {
        results.add(b.scale(t));
      } else {
        results.addAll(b.scale(t).lengths);
      }
    }

    return _CompoundDimension(combineLength(results));
  }

  double toPX({double? constraint, Size? screenSize}) {
    return lengths.fold(0, (previousValue, element) {
      return previousValue +
          element.toPX(constraint: constraint, screenSize: screenSize);
    });
  }

  @override
  int get hashCode => hashList(lengths);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is _CompoundDimension &&
        listEquals<Dimension>(other.lengths, lengths);
  }

  @override
  String toString() {
    return lengths
        .fold(
            "",
            (String previousString, element) =>
                previousString + " + " + element.toString())
        .substring(3);
  }
}

///compare two dimension values and return one in the toPX call.
abstract class _CompareDimension extends Dimension {
  final Dimension value1;
  final Dimension value2;
  const _CompareDimension({required this.value1, required this.value2});

  Map<String, dynamic> toJson() {
    return {
      "value1": value1.toJson(),
      "value2": value2.toJson(),
    };
  }

  @override
  bool get isAbsolute => value1.isAbsolute && value2.isAbsolute;

  @override
  bool get isLocal => value1.isLocal && value2.isLocal;

  @override
  Dimension? lerpFrom(Dimension? a, double t) {
    return _CompareDimension.lerp(a, this, t);
  }

  @override
  Dimension? lerpTo(Dimension? b, double t) {
    return _CompareDimension.lerp(this, b, t);
  }

  static _CompoundDimension lerp(Dimension? a, Dimension? b, double t) {
    List<Dimension> rst = [];
    if (a != null) {
      rst.add(a.scale(1.0 - t));
    }
    if (b != null) {
      rst.add(b.scale(t));
    }
    return _CompoundDimension(rst);
  }
}

class _MinDimension extends _CompareDimension {
  _MinDimension({required value1, required value2})
      : super(value1: value1, value2: value2);

  Map<String, dynamic> toJson() {
    return {"method": "min"}..addAll(super.toJson());
  }

  _MinDimension scale(double t) {
    return _MinDimension(
      value1: value1.scale(t),
      value2: value2.scale(t),
    );
  }

  Dimension operator -() {
    return _MaxDimension(value1: -value1, value2: -value2);
  }

  double toPX({double? constraint, Size? screenSize}) {
    return min(value1.toPX(constraint: constraint, screenSize: screenSize),
        value2.toPX(constraint: constraint, screenSize: screenSize));
  }

  @override
  String toString() {
    return "min(" + value1.toString() + ", " + value2.toString() + ")";
  }

  @override
  int get hashCode => hashValues(value1, value2);

  @override
  bool operator ==(dynamic other) {
    return other is _MinDimension &&
        value1 == other.value1 &&
        value2 == other.value2;
  }
}

class _MaxDimension extends _CompareDimension {
  _MaxDimension({required value1, required value2})
      : super(value1: value1, value2: value2);

  Map<String, dynamic> toJson() {
    return {"method": "max"}..addAll(super.toJson());
  }

  _MaxDimension scale(double t) {
    return _MaxDimension(
      value1: value1.scale(t),
      value2: value2.scale(t),
    );
  }

  Dimension operator -() {
    return _MinDimension(value1: -value1, value2: -value2);
  }

  double toPX({double? constraint, Size? screenSize}) {
    return max(value1.toPX(constraint: constraint, screenSize: screenSize),
        value2.toPX(constraint: constraint, screenSize: screenSize));
  }

  @override
  String toString() {
    return "max(" + value1.toString() + ", " + value2.toString() + ")";
  }

  @override
  int get hashCode => hashValues(value1, value2);

  @override
  bool operator ==(dynamic other) {
    return other is _MaxDimension &&
        value1 == other.value1 &&
        value2 == other.value2;
  }
}

class DimensionTween extends Tween<Dimension?> {
  DimensionTween({Dimension? begin, Dimension? end})
      : super(begin: begin, end: end);

  @override
  Dimension? lerp(double t) {
    return Dimension.lerp(begin, end, t);
  }
}

Dimension? parseDimension(dynamic input) {
  if (input == null) return null;
  if (input is String) {
    return parseLength(input);
  }
  if (input is List) {
    return _CompoundDimension(input.map((e) => parseDimension(e)!).toList());
  }
  if (input is Map) {
    if (input["method"] == "max") {
      return _MaxDimension(
          value1: parseDimension(input["value1"]),
          value2: parseDimension(input["value2"]));
    } else if (input["method"] == "min") {
      return _MinDimension(
          value1: parseDimension(input["value1"]),
          value2: parseDimension(input["value2"]));
    }
  }
  return null;
}
