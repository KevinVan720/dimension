import 'package:dimension/dimension.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Size portrait = Size(400, 800);
  const Size landscape = Size(800, 400);

  group('Length construction', () {
    test('defaults to px', () {
      const Length length = Length(10);
      expect(length.value, 10.0);
      expect(length.unit, LengthUnit.px);
    });

    test('keeps the given unit', () {
      for (final LengthUnit unit in LengthUnit.values) {
        final Length length = Length(3.5, unit: unit);
        expect(length.value, 3.5);
        expect(length.unit, unit);
      }
    });

    test('can be const and canonicalized', () {
      expect(identical(const Length(1), const Length(1)), isTrue);
    });
  });

  group('Length.toPX', () {
    test('px ignores constraint and screen size', () {
      expect(const Length(42).toPX(), 42.0);
      expect(
          const Length(42).toPX(constraint: 1000, screenSize: portrait), 42.0);
    });

    test('percent is relative to the constraint', () {
      const Length length = Length(25, unit: LengthUnit.percent);
      expect(length.toPX(constraint: 200), 50.0);
      expect(length.toPX(constraint: 200, screenSize: portrait), 50.0);
      expect(length.toPX(constraint: 0), 0.0);
    });

    test('percent defaults to a constraint of 100', () {
      expect(const Length(25, unit: LengthUnit.percent).toPX(), 25.0);
    });

    test('vw/vh are relative to the screen width/height', () {
      expect(const Length(10, unit: LengthUnit.vw).toPX(screenSize: portrait),
          40.0);
      expect(const Length(10, unit: LengthUnit.vh).toPX(screenSize: portrait),
          80.0);
      expect(const Length(10, unit: LengthUnit.vw).toPX(screenSize: landscape),
          80.0);
      expect(const Length(10, unit: LengthUnit.vh).toPX(screenSize: landscape),
          40.0);
    });

    test('viewport units ignore the constraint', () {
      expect(
          const Length(10, unit: LengthUnit.vw)
              .toPX(constraint: 5, screenSize: portrait),
          40.0);
    });

    test('vmin uses the shortest and vmax the longest screen side', () {
      for (final Size screen in <Size>[portrait, landscape]) {
        expect(const Length(10, unit: LengthUnit.vmin).toPX(screenSize: screen),
            40.0);
        expect(const Length(10, unit: LengthUnit.vmax).toPX(screenSize: screen),
            80.0);
      }
    });

    test('viewport units default to a 100x100 screen', () {
      for (final LengthUnit unit in <LengthUnit>[
        LengthUnit.vw,
        LengthUnit.vh,
        LengthUnit.vmin,
        LengthUnit.vmax,
      ]) {
        expect(Length(30, unit: unit).toPX(), 30.0);
      }
    });

    test('negative and fractional values', () {
      expect(const Length(-12.5).toPX(), -12.5);
      expect(const Length(-50, unit: LengthUnit.percent).toPX(constraint: 30),
          -15.0);
      expect(const Length(0.5, unit: LengthUnit.vw).toPX(screenSize: portrait),
          2.0);
    });

    test('infinite px stays infinite', () {
      expect(const Length(double.infinity).toPX(), double.infinity);
    });
  });

  group('Length.fromPX', () {
    test('returns null for null px', () {
      expect(Length.fromPX(null, LengthUnit.px), isNull);
    });

    test('converts px into each unit', () {
      expect(Length.fromPX(30, LengthUnit.px), 30.0);
      expect(Length.fromPX(30, LengthUnit.percent, constraint: 300), 10.0);
      expect(Length.fromPX(30, LengthUnit.percent), 30.0);
      expect(Length.fromPX(40, LengthUnit.vw, screenSize: portrait), 10.0);
      expect(Length.fromPX(80, LengthUnit.vh, screenSize: portrait), 10.0);
      expect(Length.fromPX(40, LengthUnit.vmin, screenSize: landscape), 10.0);
      expect(Length.fromPX(80, LengthUnit.vmax, screenSize: landscape), 10.0);
      expect(Length.fromPX(30, LengthUnit.vw), 30.0);
    });

    test('is the inverse of toPX', () {
      for (final LengthUnit unit in LengthUnit.values) {
        final double value =
            Length.fromPX(123, unit, constraint: 250, screenSize: portrait)!;
        expect(
            Length(value, unit: unit)
                .toPX(constraint: 250, screenSize: portrait),
            closeTo(123, 1e-9));
      }
    });
  });

  group('Length.copyWith', () {
    test('without arguments returns an equal Length', () {
      const Length length = Length(5, unit: LengthUnit.vh);
      expect(length.copyWith(), length);
    });

    test('replaces value and/or unit', () {
      const Length length = Length(5, unit: LengthUnit.vh);
      expect(length.copyWith(value: 7), const Length(7, unit: LengthUnit.vh));
      expect(length.copyWith(unit: LengthUnit.px), const Length(5));
      expect(length.copyWith(value: 1, unit: LengthUnit.percent),
          const Length(1, unit: LengthUnit.percent));
    });
  });

  group('Length arithmetic helpers', () {
    test('unary minus negates the value and keeps the unit', () {
      const Length length = Length(5, unit: LengthUnit.vw);
      final Length negated = -length;
      expect(negated, const Length(-5, unit: LengthUnit.vw));
      expect(-negated, length);
    });

    test('scale multiplies the value and keeps the unit', () {
      const Length length = Length(5, unit: LengthUnit.vmin);
      expect(length.scale(2), const Length(10, unit: LengthUnit.vmin));
      expect(length.scale(0), const Length(0, unit: LengthUnit.vmin));
      expect(length.scale(-0.5), const Length(-2.5, unit: LengthUnit.vmin));
    });
  });

  group('Length.isAbsolute / isLocal', () {
    test('isAbsolute is false only for percent', () {
      for (final LengthUnit unit in LengthUnit.values) {
        expect(Length(1, unit: unit).isAbsolute, unit != LengthUnit.percent,
            reason: unit.toString());
      }
    });

    test('isLocal is false only for viewport units', () {
      expect(const Length(1).isLocal, isTrue);
      expect(const Length(1, unit: LengthUnit.percent).isLocal, isTrue);
      expect(const Length(1, unit: LengthUnit.vw).isLocal, isFalse);
      expect(const Length(1, unit: LengthUnit.vh).isLocal, isFalse);
      expect(const Length(1, unit: LengthUnit.vmin).isLocal, isFalse);
      expect(const Length(1, unit: LengthUnit.vmax).isLocal, isFalse);
    });
  });

  group('Length equality', () {
    test('equal value and unit are equal with equal hashCodes', () {
      final Length a = Length(10, unit: LengthUnit.vw);
      final Length b = Length(10.0, unit: LengthUnit.vw);
      expect(identical(a, b), isFalse);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test('different value or unit are not equal', () {
      expect(const Length(10) == const Length(11), isFalse);
      expect(const Length(10) == const Length(10, unit: LengthUnit.percent),
          isFalse);
    });

    test('is not equal to other types', () {
      // ignore: unrelated_type_equality_checks
      expect(const Length(10) == 10, isFalse);
      // ignore: unrelated_type_equality_checks
      expect(const Length(10) == '10.0px', isFalse);
    });

    test('0.0 and -0.0 are equal with equal hashCodes', () {
      expect(const Length(0.0) == const Length(-0.0), isTrue);
      expect(const Length(0.0).hashCode, const Length(-0.0).hashCode);
    });

    test('works as a Set/Map key', () {
      final Set<Dimension> set = <Dimension>{
        const Length(1),
        Length(1.0),
        const Length(1, unit: LengthUnit.vw),
      };
      expect(set, hasLength(2));
    });
  });

  group('Length.getUnit', () {
    test('returns the serialized unit symbol', () {
      expect(const Length(1).getUnit(), 'px');
      expect(const Length(1, unit: LengthUnit.percent).getUnit(), '%');
      expect(const Length(1, unit: LengthUnit.vw).getUnit(), 'vw');
      expect(const Length(1, unit: LengthUnit.vh).getUnit(), 'vh');
      expect(const Length(1, unit: LengthUnit.vmin).getUnit(), 'vmin');
      expect(const Length(1, unit: LengthUnit.vmax).getUnit(), 'vmax');
    });
  });

  group('Length.toString', () {
    test('rounds to one decimal and appends a unit label', () {
      expect(const Length(10).toString(), '10.0px');
      expect(const Length(10.26).toString(), '10.3px');
      expect(const Length(10, unit: LengthUnit.percent).toString(), '10.0%');
      expect(const Length(10, unit: LengthUnit.vw).toString(), '10.0%vw');
      expect(const Length(10, unit: LengthUnit.vh).toString(), '10.0%vh');
      expect(const Length(10, unit: LengthUnit.vmin).toString(), '10.0%vmin');
      expect(const Length(10, unit: LengthUnit.vmax).toString(), '10.0%vmax');
    });

    test('small negative values print as 0.0', () {
      expect(const Length(-0.04).toString(), '0.0px');
      expect(const Length(-0.06).toString(), '-0.1px');
    });

    test('does not throw for non-finite values', () {
      expect(const Length(double.infinity).toString(), 'Infinitypx');
      expect(const Length(double.negativeInfinity).toString(), '-Infinitypx');
      expect(const Length(double.nan).toString(), 'NaNpx');
    });

    test('does not overflow for huge values', () {
      expect(const Length(1e300).toString(), '1e+300px');
    });
  });
}
