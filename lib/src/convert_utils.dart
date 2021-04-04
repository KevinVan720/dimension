import 'dart:math';

import '../dimension.dart';

extension DoubleRoundingExtension on double {
  double roundWithPrecision(int N) {
    return (this * pow(10.0, N)).round() / pow(10.0, N);
  }

  double roundWithNumber(double base) {
    return (this * base).round() / base;
  }

  double alignmentValueToPercent() {
    return (this + 1.0) / 2 * 100;
  }

  double percentToAlignmentValue() {
    return this / 100 * 2 - 1.0;
  }
}

extension DoubleToLengthExtension on double {
  Length toLength({LengthUnit? unit}) {
    if (unit != null) {
      return Length(this, unit: unit);
    }
    return Length(this);
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

extension IntToLengthExtension on int {
  Length toLength({LengthUnit? unit}) {
    if (unit != null) {
      return Length(this.toDouble(), unit: unit);
    }
    return Length(this.toDouble());
  }

  Length get toPXLength {
    return Length(this.toDouble());
  }

  Length get toPercentLength {
    return Length(this.toDouble(), unit: LengthUnit.percent);
  }

  Length get toVWLength {
    return Length(this.toDouble(), unit: LengthUnit.vw);
  }

  Length get toVHLength {
    return Length(this.toDouble(), unit: LengthUnit.vh);
  }

  Length get toVMINLength {
    return Length(this.toDouble(), unit: LengthUnit.vmin);
  }

  Length get toVMAXLength {
    return Length(this.toDouble(), unit: LengthUnit.vmax);
  }
}
