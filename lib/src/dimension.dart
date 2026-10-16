import 'dart:convert' show json;
import 'dart:math' as math;
import 'dart:ui' show Size;

import 'package:flutter/animation.dart' show Tween;
import 'package:flutter/foundation.dart';

import 'convert_utils.dart';
import 'length_unit.dart';

///Base class of Dimension. Convert to actual px value by calling
///the toPX() function and provide a constraint value and the screen size.
abstract class Dimension {
  const Dimension();

  /// A JSON compatible representation (a [String], [List] or [Map]) that can
  /// be read back with [parseDimension].
  dynamic toJson();

  /// The value in logical pixels.
  ///
  /// [constraint] is the parent size that percentages are relative to and
  /// [screenSize] the size that viewport units (vw, vh, vmin, vmax) are
  /// relative to. Both default to 100 when null.
  double toPX({double? constraint, Size? screenSize});

  /// Returns `this + other` if this dimension knows how to simplify the sum,
  /// otherwise null.
  @protected
  Dimension? add(Dimension other) => null;

  Dimension operator +(Dimension other) {
    return add(other) ??
        other.add(this) ??
        _CompoundDimension(<Dimension>[other, this]);
  }

  Dimension operator -();

  Dimension operator -(Dimension other) {
    final Dimension negated = -other;
    return add(negated) ??
        negated.add(this) ??
        _CompoundDimension(<Dimension>[negated, this]);
  }

  /// Multiplies this dimension by [t].
  Dimension scale(double t);

  ///does not depend on parent dimension (no % unit)
  bool get isAbsolute => true;

  ///does not depend on viewport size (no VH,VW,VMIN,VMAX unit)
  bool get isLocal => true;

  /// The larger of [value1] and [value2], like CSS `max()`.
  static Dimension max(Dimension value1, Dimension value2) {
    return _MaxDimension(value1, value2);
  }

  /// The smaller of [value1] and [value2], like CSS `min()`.
  static Dimension min(Dimension value1, Dimension value2) {
    return _MinDimension(value1, value2);
  }

  /// [value] clamped between [min] and [max], like CSS `clamp()`, which is
  /// `max(min, min(value, max))`.
  static Dimension clamp(Dimension min, Dimension value, Dimension max) {
    return _MaxDimension(min, _MinDimension(value, max));
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

  /// Linearly interpolates between [a] and [b], treating null as zero.
  /// Returns null if both are null.
  ///
  /// Works across units and expressions: the px value of the result is
  /// `a.toPX() * (1 - t) + b.toPX() * t`.
  static Dimension? lerp(Dimension? a, Dimension? b, double t) {
    Dimension? result;
    if (b != null) result = b.lerpFrom(a, t);
    if (result == null && a != null) result = a.lerpTo(b, t);
    return result ?? (t < 0.5 ? a : b);
  }
}

///This is the one actually used by users.
///Contains a value and a unit
class Length extends Dimension {
  final double value;
  final LengthUnit unit;

  const Length(this.value, {this.unit = LengthUnit.px});

  /// Parses a length written as `<number><unit>`, e.g. `"10.0px"`, `"50%"`
  /// or `"1e-7vw"`, as produced by [toJson].
  ///
  /// A number without a unit, or with an unknown unit, is read as px.
  /// Input that does not start with a number is read as 0.
  static Length? fromJson(String? string) {
    if (string == null) return null;
    final String trimmed = string.trim();
    for (final MapEntry<String, LengthUnit> entry in lengthUnitMap.entries) {
      if (trimmed.endsWith(entry.key)) {
        final double? value = double.tryParse(
            trimmed.substring(0, trimmed.length - entry.key.length));
        if (value != null) return Length(value, unit: entry.value);
      }
    }
    final double? value = double.tryParse(trimmed);
    if (value != null) return Length(value);

    // Lenient fallback for anything else: split at the first letter.
    final int index = string.indexOf(RegExp('[a-zA-Z%]'));
    if (index == -1) return const Length(0);
    return Length(double.tryParse(string.substring(0, index)) ?? 0,
        unit: parseLengthUnit(string.substring(index)) ?? LengthUnit.px);
  }

  /// The unit symbol used by [toJson], e.g. `px` or `%`.
  String getUnit() {
    if (unit == LengthUnit.percent) return '%';
    return unit.name;
  }

  @override
  String toJson() {
    return '$value${getUnit()}';
  }

  @override
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
    return _CompoundDimension.lerp(a, this, t);
  }

  @override
  Dimension? lerpTo(Dimension? b, double t) {
    return _CompoundDimension.lerp(this, b, t);
  }

  @override
  double toPX({double? constraint, Size? screenSize}) {
    return switch (unit) {
      LengthUnit.px => value,
      LengthUnit.percent => value / 100.0 * (constraint ?? 100.0),
      LengthUnit.vw => value / 100.0 * (screenSize?.width ?? 100.0),
      LengthUnit.vh => value / 100.0 * (screenSize?.height ?? 100.0),
      LengthUnit.vmin => value / 100.0 * (screenSize?.shortestSide ?? 100.0),
      LengthUnit.vmax => value / 100.0 * (screenSize?.longestSide ?? 100.0),
    };
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

  /// Converts [px] into a value of [unit], the inverse of [toPX].
  static double? fromPX(double? px, LengthUnit unit,
      {double? constraint, Size? screenSize}) {
    if (px == null) return null;
    return switch (unit) {
      LengthUnit.px => px,
      LengthUnit.percent => px / (constraint ?? 100.0) * 100.0,
      LengthUnit.vw => px / (screenSize?.width ?? 100.0) * 100.0,
      LengthUnit.vh => px / (screenSize?.height ?? 100.0) * 100.0,
      LengthUnit.vmin => px / (screenSize?.shortestSide ?? 100.0) * 100.0,
      LengthUnit.vmax => px / (screenSize?.longestSide ?? 100.0) * 100.0,
    };
  }

  @override
  Length operator -() => copyWith(value: -value);

  @override
  int get hashCode => Object.hash(value, unit);

  @override
  bool operator ==(Object other) {
    return other is Length && value == other.value && unit == other.unit;
  }

  @override
  String toString() {
    final String rounded = value.roundWithPrecision(1).toString();
    return switch (unit) {
      LengthUnit.px => '${rounded}px',
      LengthUnit.percent => '$rounded%',
      LengthUnit.vw => '$rounded%vw',
      LengthUnit.vh => '$rounded%vh',
      LengthUnit.vmin => '$rounded%vmin',
      LengthUnit.vmax => '$rounded%vmax',
    };
  }
}

///compound dimension, basically a list of dimension values
class _CompoundDimension extends Dimension {
  _CompoundDimension(List<Dimension> lengths)
      : assert(lengths.length >= 2),
        lengths = List<Dimension>.unmodifiable(lengths);

  final List<Dimension> lengths;

  /// The simplest dimension that is the sum of [lengths].
  static Dimension sum(List<Dimension> lengths) {
    return switch (lengths.length) {
      0 => const Length(0),
      1 => lengths.single,
      _ => _CompoundDimension(lengths),
    };
  }

  /// The terms of [dimension] if it is a sum, otherwise [dimension] itself.
  static Iterable<Dimension> terms(Dimension dimension) {
    return dimension is _CompoundDimension
        ? dimension.lengths
        : <Dimension>[dimension];
  }

  @override
  List<dynamic> toJson() {
    return lengths.map((Dimension e) => e.toJson()).toList();
  }

  @override
  _CompoundDimension scale(double t) {
    return _CompoundDimension(
        lengths.map((Dimension e) => e.scale(t)).toList());
  }

  @override
  bool get isAbsolute => lengths.every((Dimension e) => e.isAbsolute);

  @override
  bool get isLocal => lengths.every((Dimension e) => e.isLocal);

  /// Merges the [Length]s with the same unit, keeping the order in which each
  /// unit first appears.
  static List<Dimension> combineLength(Iterable<Dimension> list) {
    final List<Dimension> rst = <Dimension>[];
    for (final Dimension element in list) {
      if (element is Length) {
        final int index = rst
            .indexWhere((Dimension e) => e is Length && e.unit == element.unit);
        if (index != -1) {
          rst[index] = Length((rst[index] as Length).value + element.value,
              unit: element.unit);
          continue;
        }
      }
      rst.add(element);
    }
    return rst;
  }

  @override
  Dimension? add(Dimension other) {
    return sum(combineLength(<Dimension>[...lengths, ...terms(other)]));
  }

  @override
  Dimension operator -() {
    return _CompoundDimension(lengths.map((Dimension e) => -e).toList());
  }

  @override
  Dimension? lerpFrom(Dimension? a, double t) {
    return _CompoundDimension.lerp(a, this, t);
  }

  @override
  Dimension? lerpTo(Dimension? b, double t) {
    return _CompoundDimension.lerp(this, b, t);
  }

  /// Linear interpolation as the sum `a * (1 - t) + b * t`, where a null
  /// dimension counts as zero.
  static Dimension lerp(Dimension? a, Dimension? b, double t) {
    return sum(combineLength(<Dimension>[
      if (a != null) ...terms(a.scale(1.0 - t)),
      if (b != null) ...terms(b.scale(t)),
    ]));
  }

  @override
  double toPX({double? constraint, Size? screenSize}) {
    return lengths.fold(0.0, (double previousValue, Dimension element) {
      return previousValue +
          element.toPX(constraint: constraint, screenSize: screenSize);
    });
  }

  @override
  int get hashCode => Object.hashAll(lengths);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _CompoundDimension &&
        listEquals<Dimension>(other.lengths, lengths);
  }

  @override
  String toString() => lengths.join(' + ');
}

///compare two dimension values and return one in the toPX call.
abstract class _CompareDimension extends Dimension {
  const _CompareDimension(this.value1, this.value2);

  final Dimension value1;
  final Dimension value2;

  /// The name of the comparison, used for serialization.
  String get method;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'value1': value1.toJson(),
      'value2': value2.toJson(),
    };
  }

  @override
  bool get isAbsolute => value1.isAbsolute && value2.isAbsolute;

  @override
  bool get isLocal => value1.isLocal && value2.isLocal;

  @override
  Dimension? lerpFrom(Dimension? a, double t) {
    return _CompoundDimension.lerp(a, this, t);
  }

  @override
  Dimension? lerpTo(Dimension? b, double t) {
    return _CompoundDimension.lerp(this, b, t);
  }

  @override
  String toString() => '$method($value1, $value2)';
}

class _MinDimension extends _CompareDimension {
  const _MinDimension(super.value1, super.value2);

  @override
  String get method => 'min';

  /// min(a, b) * t is max(a * t, b * t) for a negative t.
  @override
  _CompareDimension scale(double t) {
    return t < 0
        ? _MaxDimension(value1.scale(t), value2.scale(t))
        : _MinDimension(value1.scale(t), value2.scale(t));
  }

  @override
  Dimension operator -() {
    return _MaxDimension(-value1, -value2);
  }

  @override
  double toPX({double? constraint, Size? screenSize}) {
    return math.min(value1.toPX(constraint: constraint, screenSize: screenSize),
        value2.toPX(constraint: constraint, screenSize: screenSize));
  }

  @override
  int get hashCode => Object.hash(value1, value2);

  @override
  bool operator ==(Object other) {
    return other is _MinDimension &&
        value1 == other.value1 &&
        value2 == other.value2;
  }
}

class _MaxDimension extends _CompareDimension {
  const _MaxDimension(super.value1, super.value2);

  @override
  String get method => 'max';

  /// max(a, b) * t is min(a * t, b * t) for a negative t.
  @override
  _CompareDimension scale(double t) {
    return t < 0
        ? _MinDimension(value1.scale(t), value2.scale(t))
        : _MaxDimension(value1.scale(t), value2.scale(t));
  }

  @override
  Dimension operator -() {
    return _MinDimension(-value1, -value2);
  }

  @override
  double toPX({double? constraint, Size? screenSize}) {
    return math.max(value1.toPX(constraint: constraint, screenSize: screenSize),
        value2.toPX(constraint: constraint, screenSize: screenSize));
  }

  @override
  int get hashCode => Object.hash(value1, value2);

  @override
  bool operator ==(Object other) {
    return other is _MaxDimension &&
        value1 == other.value1 &&
        value2 == other.value2;
  }
}

/// A [Tween] between two dimensions, see [Dimension.lerp].
class DimensionTween extends Tween<Dimension?> {
  DimensionTween({super.begin, super.end});

  @override
  Dimension? lerp(double t) {
    return Dimension.lerp(begin, end, t);
  }
}

/// Same as [Length.fromJson].
Length? parseLength(String? string) {
  return Length.fromJson(string);
}

/// Parses the output of [Dimension.toJson] back into a [Dimension].
///
/// Accepts the decoded JSON value (a [String], [List] or [Map]) as well as
/// the JSON encoded text of a list, map or string. Numbers are read as px.
/// Returns null if [input] is null or not a dimension.
Dimension? parseDimension(dynamic input) {
  if (input == null) return null;
  if (input is String) {
    final Object? decoded = _tryDecodeJson(input);
    if (decoded != null) return parseDimension(decoded);
    return parseLength(input);
  }
  if (input is num) {
    return Length(input.toDouble());
  }
  if (input is List) {
    return _CompoundDimension.sum(
        input.map(parseDimension).whereType<Dimension>().toList());
  }
  if (input is Map) {
    final Object? method = input['method'];
    if (method != 'max' && method != 'min') return null;
    final Dimension? value1 = parseDimension(input['value1']);
    final Dimension? value2 = parseDimension(input['value2']);
    if (value1 == null || value2 == null) return value1 ?? value2;
    return method == 'max'
        ? _MaxDimension(value1, value2)
        : _MinDimension(value1, value2);
  }
  return null;
}

/// Decodes [input] if it is the JSON encoding of a list, map or string.
Object? _tryDecodeJson(String input) {
  final String trimmed = input.trimLeft();
  if (trimmed.isEmpty || !'[{"'.contains(trimmed[0])) return null;
  try {
    return json.decode(input);
  } on FormatException {
    return null;
  }
}
