import 'package:dimension/dimension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntToLengthExtension', () {
    test('creates lengths with each unit', () {
      expect(10.toPXLength, const Length(10));
      expect(10.toPercentLength, const Length(10, unit: LengthUnit.percent));
      expect(10.toVWLength, const Length(10, unit: LengthUnit.vw));
      expect(10.toVHLength, const Length(10, unit: LengthUnit.vh));
      expect(10.toVMINLength, const Length(10, unit: LengthUnit.vmin));
      expect(10.toVMAXLength, const Length(10, unit: LengthUnit.vmax));
    });

    test('toLength defaults to px', () {
      expect(10.toLength(), const Length(10));
      expect(10.toLength(unit: LengthUnit.vh),
          const Length(10, unit: LengthUnit.vh));
    });

    test('values are doubles', () {
      expect(10.toPXLength.value, isA<double>());
      expect(10.toLength().value, isA<double>());
    });
  });

  group('DoubleToLengthExtension', () {
    test('creates lengths with each unit', () {
      expect(2.5.toPXLength, const Length(2.5));
      expect(2.5.toPercentLength, const Length(2.5, unit: LengthUnit.percent));
      expect(2.5.toVWLength, const Length(2.5, unit: LengthUnit.vw));
      expect(2.5.toVHLength, const Length(2.5, unit: LengthUnit.vh));
      expect(2.5.toVMINLength, const Length(2.5, unit: LengthUnit.vmin));
      expect(2.5.toVMAXLength, const Length(2.5, unit: LengthUnit.vmax));
    });

    test('toLength defaults to px', () {
      expect(2.5.toLength(), const Length(2.5));
      expect(2.5.toLength(unit: LengthUnit.vmax),
          const Length(2.5, unit: LengthUnit.vmax));
    });
  });

  group('DoubleRoundingExtension', () {
    test('roundWithPrecision', () {
      expect(1.26.roundWithPrecision(1), 1.3);
      expect(1.24.roundWithPrecision(1), 1.2);
      expect(3.14159.roundWithPrecision(2), 3.14);
      expect(3.14159.roundWithPrecision(0), 3.0);
      expect(1234.5.roundWithPrecision(-2), 1200.0);
      expect((-1.26).roundWithPrecision(1), -1.3);
    });

    test('roundWithPrecision returns a positive zero', () {
      final double rounded = (-0.04).roundWithPrecision(1);
      expect(rounded, 0.0);
      expect(rounded.isNegative, isFalse);
    });

    test('roundWithPrecision keeps non-finite and huge values', () {
      expect(double.infinity.roundWithPrecision(1), double.infinity);
      expect(double.negativeInfinity.roundWithPrecision(1),
          double.negativeInfinity);
      expect(double.nan.roundWithPrecision(1).isNaN, isTrue);
      expect(1e300.roundWithPrecision(1), 1e300);
      expect((-1e20).roundWithPrecision(2), -1e20);
    });

    test('roundWithNumber rounds to multiples of 1/base', () {
      expect(1.26.roundWithNumber(4), 1.25);
      expect(1.4.roundWithNumber(2), 1.5);
      expect(1.2.roundWithNumber(2), 1.0);
      expect(double.infinity.roundWithNumber(2), double.infinity);
    });

    test('alignment <-> percent conversions', () {
      expect((-1.0).alignmentValueToPercent(), 0.0);
      expect(0.0.alignmentValueToPercent(), 50.0);
      expect(1.0.alignmentValueToPercent(), 100.0);
      expect(0.0.percentToAlignmentValue(), -1.0);
      expect(50.0.percentToAlignmentValue(), 0.0);
      expect(100.0.percentToAlignmentValue(), 1.0);
      expect(0.5.alignmentValueToPercent().percentToAlignmentValue(), 0.5);
    });
  });
}
