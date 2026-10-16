import 'dart:math' as math;

import 'dimension.dart';
import 'length_unit.dart';

/// Rounding and alignment helpers on [double].
extension DoubleRoundingExtension on double {
  /// Rounds to [precision] decimal places (a negative [precision] rounds to
  /// tens, hundreds, ...).
  double roundWithPrecision(int precision) {
    return _roundWithFactor(math.pow(10.0, precision).toDouble());
  }

  /// Rounds to the nearest multiple of `1 / base`.
  double roundWithNumber(double base) {
    return _roundWithFactor(base);
  }

  double alignmentValueToPercent() {
    return (this + 1.0) / 2 * 100;
  }

  double percentToAlignmentValue() {
    return this / 100 * 2 - 1.0;
  }

  double _roundWithFactor(double factor) {
    final double scaled = this * factor;
    // Infinite and NaN values cannot be rounded, and values this large have
    // no fractional digits left to round.
    if (!scaled.isFinite) return this;
    final double rounded = scaled.roundToDouble() / factor;
    // Never return -0.0, like the former int based rounding.
    return rounded == 0 ? 0.0 : rounded;
  }
}

///extension for creating Length instance from double or int
extension DoubleToLengthExtension on double {
  Length toLength({LengthUnit? unit}) {
    return Length(this, unit: unit ?? LengthUnit.px);
  }

  Length get toPXLength {
    return Length(this);
  }

  Length get toPercentLength {
    return Length(this, unit: LengthUnit.percent);
  }

  Length get toVWLength {
    return Length(this, unit: LengthUnit.vw);
  }

  Length get toVHLength {
    return Length(this, unit: LengthUnit.vh);
  }

  Length get toVMINLength {
    return Length(this, unit: LengthUnit.vmin);
  }

  Length get toVMAXLength {
    return Length(this, unit: LengthUnit.vmax);
  }
}

///extension for creating Length instance from double or int
extension IntToLengthExtension on int {
  Length toLength({LengthUnit? unit}) {
    return Length(toDouble(), unit: unit ?? LengthUnit.px);
  }

  Length get toPXLength {
    return Length(toDouble());
  }

  Length get toPercentLength {
    return Length(toDouble(), unit: LengthUnit.percent);
  }

  Length get toVWLength {
    return Length(toDouble(), unit: LengthUnit.vw);
  }

  Length get toVHLength {
    return Length(toDouble(), unit: LengthUnit.vh);
  }

  Length get toVMINLength {
    return Length(toDouble(), unit: LengthUnit.vmin);
  }

  Length get toVMAXLength {
    return Length(toDouble(), unit: LengthUnit.vmax);
  }
}
