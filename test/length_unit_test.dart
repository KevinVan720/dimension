import 'package:dimension/dimension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LengthUnit values', () {
    expect(LengthUnit.values, <LengthUnit>[
      LengthUnit.px,
      LengthUnit.percent,
      LengthUnit.vw,
      LengthUnit.vh,
      LengthUnit.vmin,
      LengthUnit.vmax,
    ]);
  });

  test('lengthUnitMap maps every unit symbol to its unit', () {
    expect(lengthUnitMap, <String, LengthUnit>{
      '%': LengthUnit.percent,
      'px': LengthUnit.px,
      'vh': LengthUnit.vh,
      'vw': LengthUnit.vw,
      'vmin': LengthUnit.vmin,
      'vmax': LengthUnit.vmax,
    });
    for (final LengthUnit unit in LengthUnit.values) {
      expect(lengthUnitMap[Length(1, unit: unit).getUnit()], unit);
    }
  });

  group('parseLengthUnit', () {
    test('parses every symbol', () {
      expect(parseLengthUnit('px'), LengthUnit.px);
      expect(parseLengthUnit('%'), LengthUnit.percent);
      expect(parseLengthUnit('vw'), LengthUnit.vw);
      expect(parseLengthUnit('vh'), LengthUnit.vh);
      expect(parseLengthUnit('vmin'), LengthUnit.vmin);
      expect(parseLengthUnit('vmax'), LengthUnit.vmax);
    });

    test('returns null for null, blank or unknown symbols', () {
      expect(parseLengthUnit(null), isNull);
      expect(parseLengthUnit(''), isNull);
      expect(parseLengthUnit('   '), isNull);
      expect(parseLengthUnit('em'), isNull);
      expect(parseLengthUnit('PX'), isNull);
      expect(parseLengthUnit('percent'), isNull);
    });

    test('ignores surrounding whitespace', () {
      expect(parseLengthUnit(' vw '), LengthUnit.vw);
      expect(parseLengthUnit('%\n'), LengthUnit.percent);
    });
  });
}
