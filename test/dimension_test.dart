import 'package:dimension/dimension.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const Size screen = Size(400, 800);
const double constraint = 200;

double px(Dimension dimension) =>
    dimension.toPX(constraint: constraint, screenSize: screen);

void main() {
  group('addition and subtraction', () {
    test('adds lengths of different units', () {
      final Dimension sum = 10.toPXLength + 5.toVWLength;
      expect(px(sum), 30.0);
      expect(sum.isAbsolute, isTrue);
      expect(sum.isLocal, isFalse);
    });

    test('subtracts lengths', () {
      final Dimension diff = 100.toVWLength - 10.toPXLength;
      expect(px(diff), 390.0);
    });

    test('chains additions and subtractions', () {
      final Dimension length =
          100.toVWLength - 10.toPXLength + 20.toPercentLength;
      expect(px(length), 400 - 10 + 40.0);
      expect(length.isAbsolute, isFalse);
      expect(length.isLocal, isFalse);
    });

    test('adds and subtracts lengths of the same unit', () {
      expect(px(1.toPXLength + 2.toPXLength), 3.0);
      expect(px(10.toPXLength - 10.toPXLength), 0.0);
      expect(px(1.toPXLength + 2.toPXLength + 3.toPXLength), 6.0);
      expect(px(1.toPXLength + 2.toPXLength - 3.toPXLength), 0.0);
      expect(px(5.toVWLength + 5.toVWLength + 5.toVWLength), 60.0);
    });

    test('keeps the order of the operands in the serialized form', () {
      expect(
          (10.toPXLength + 5.toVWLength).toJson(), <String>['5.0vw', '10.0px']);
      expect(
          (1.toPXLength + 2.toPXLength).toJson(), <String>['2.0px', '1.0px']);
      expect((100.toVWLength - 10.toPXLength + 20.toPercentLength).toJson(),
          <String>['-10.0px', '100.0vw', '20.0%']);
    });

    test('merges lengths of the same unit when extending a sum', () {
      final Dimension sum = (5.toVWLength + 3.toPXLength) + 10.toPXLength;
      expect(sum.toJson(), <String>['13.0px', '5.0vw']);
      expect(px(sum), 33.0);

      final Dimension sum2 =
          (5.toVWLength + 3.toPXLength) + (1.toPXLength + 2.toVHLength);
      expect(sum2.toJson(), <String>['4.0px', '5.0vw', '2.0vh']);
      expect(px(sum2), 4 + 20 + 16.0);
    });

    test('adding to a sum does not modify the original sum', () {
      final Dimension base = 10.toPXLength + 5.toVWLength;
      final List<dynamic> json = base.toJson() as List<dynamic>;

      final Dimension added = base + 3.toPXLength;
      final Dimension subtracted = base - 3.toPXLength;
      final Dimension added2 = 3.toPXLength + base;
      final Dimension subtracted2 = 3.toPXLength - base;

      expect(px(added), 33.0);
      expect(px(subtracted), 27.0);
      expect(px(added2), 33.0);
      expect(px(subtracted2), -27.0);
      expect(px(base), 30.0);
      expect(base.toJson(), json);
    });

    test('a sum can be added to itself', () {
      final Dimension base = 10.toPXLength + 5.toVWLength;
      expect(px(base + base), 60.0);
      expect(px(base - base), 0.0);
      expect(px(base), 30.0);
    });

    test('adds min/max expressions', () {
      final Dimension sum =
          Dimension.max(10.toPXLength, 20.toPXLength) + 5.toPXLength;
      expect(px(sum), 25.0);
      expect(px(5.toPXLength - Dimension.min(1.toPXLength, 2.toPXLength)), 4.0);
      expect(sum.toJson(), <dynamic>[
        '5.0px',
        <String, dynamic>{
          'method': 'max',
          'value1': '10.0px',
          'value2': '20.0px',
        },
      ]);
    });
  });

  group('min / max / clamp', () {
    test('max picks the larger px value', () {
      expect(px(Dimension.max(20.toPercentLength, 700.toPXLength)), 700.0);
      expect(px(Dimension.max(20.toPercentLength, 7.toPXLength)), 40.0);
    });

    test('min picks the smaller px value', () {
      expect(px(Dimension.min(20.toPercentLength, 700.toPXLength)), 40.0);
      expect(px(Dimension.min(20.toPercentLength, 7.toPXLength)), 7.0);
    });

    test('clamp is max(min, min(value, max))', () {
      expect(px(Dimension.clamp(200.toPXLength, 40.toVWLength, 200.toPXLength)),
          200.0);
      expect(
          px(Dimension.clamp(
              10.toPXLength, 50.toPercentLength, 100.toVWLength)),
          100.0);
      expect(
          px(Dimension.clamp(10.toPXLength, 1.toPercentLength, 100.toVWLength)),
          10.0);
      expect(
          px(Dimension.clamp(
              10.toPXLength, 500.toPercentLength, 100.toVWLength)),
          400.0);

      expect(
          Dimension.clamp(10.toPXLength, 50.toPercentLength, 100.toVWLength),
          Dimension.max(10.toPXLength,
              Dimension.min(50.toPercentLength, 100.toVWLength)));
    });

    test('nested expressions', () {
      final Dimension value = 50.toVHLength +
          10.toPercentLength -
          Dimension.min(4.toPercentLength, 40.toPXLength);
      expect(px(value), 400 + 20 - 8.0);
    });

    test('isAbsolute / isLocal combine their operands', () {
      expect(Dimension.max(1.toPXLength, 2.toPXLength).isAbsolute, isTrue);
      expect(Dimension.max(1.toPXLength, 2.toPXLength).isLocal, isTrue);
      expect(
          Dimension.max(1.toPXLength, 2.toPercentLength).isAbsolute, isFalse);
      expect(
          Dimension.min(1.toPercentLength, 2.toPXLength).isAbsolute, isFalse);
      expect(Dimension.min(1.toVWLength, 2.toPXLength).isLocal, isFalse);
      expect(Dimension.max(1.toPXLength, 2.toVMAXLength).isLocal, isFalse);
      expect(Dimension.min(1.toPercentLength, 2.toPXLength).isLocal, isTrue);
    });
  });

  group('negation', () {
    test('negates sums', () {
      final Dimension sum = 10.toPXLength + 5.toVWLength;
      expect(px(-sum), -30.0);
      expect(px(-(-sum)), 30.0);
      expect((-sum).toJson(), <String>['-5.0vw', '-10.0px']);
    });

    test('negating max gives min of the negated values and vice versa', () {
      final Dimension max = Dimension.max(10.toPXLength, 20.toPXLength);
      final Dimension min = Dimension.min(10.toPXLength, 20.toPXLength);
      expect(px(-max), -20.0);
      expect(px(-min), -10.0);
      expect(-max, Dimension.min(-10.toPXLength, -20.toPXLength));
      expect(-min, Dimension.max(-10.toPXLength, -20.toPXLength));
    });
  });

  group('scale', () {
    test('scales sums', () {
      final Dimension sum = 10.toPXLength + 5.toVWLength;
      expect(px(sum.scale(2)), 60.0);
      expect(px(sum.scale(0)), 0.0);
      expect(px(sum.scale(-1)), -30.0);
    });

    test('scales min/max by a non-negative factor', () {
      final Dimension max = Dimension.max(10.toPXLength, 20.toPXLength);
      final Dimension min = Dimension.min(10.toPXLength, 20.toPXLength);
      expect(px(max.scale(2)), 40.0);
      expect(px(min.scale(2)), 20.0);
      expect(px(max.scale(0)), 0.0);
      expect(max.scale(2), Dimension.max(20.toPXLength, 40.toPXLength));
    });

    test('scales min/max by a negative factor', () {
      final Dimension max = Dimension.max(10.toPXLength, 20.toPXLength);
      final Dimension min = Dimension.min(10.toPXLength, 20.toPXLength);
      expect(px(max.scale(-1)), -20.0);
      expect(px(min.scale(-1)), -10.0);
      expect(px(max.scale(-0.5)), -10.0);

      final Dimension clamp =
          Dimension.clamp(10.toPXLength, 50.toPercentLength, 300.toPXLength);
      for (final double t in <double>[-2, -1, -0.25, 0, 0.5, 1, 3]) {
        expect(px(clamp.scale(t)), closeTo(px(clamp) * t, 1e-9),
            reason: 't = $t');
      }
    });
  });

  group('equality', () {
    test('sums built the same way are equal', () {
      final Dimension a = 10.toPXLength + 5.toVWLength;
      final Dimension b = 10.toPXLength + 5.toVWLength;
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == 10.toPXLength + 6.toVWLength, isFalse);
      expect(a == 5.toVWLength, isFalse);
    });

    test('min/max built the same way are equal', () {
      final Dimension a = Dimension.max(10.toPXLength, 5.toVWLength);
      final Dimension b = Dimension.max(10.toPXLength, 5.toVWLength);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(Dimension.min(10.toPXLength, 5.toVWLength),
          Dimension.min(10.toPXLength, 5.toVWLength));
      expect(Dimension.min(10.toPXLength, 5.toVWLength).hashCode,
          Dimension.min(10.toPXLength, 5.toVWLength).hashCode);
    });

    test('min and max are never equal to each other', () {
      expect(
          Dimension.max(10.toPXLength, 5.toVWLength) ==
              Dimension.min(10.toPXLength, 5.toVWLength),
          isFalse);
      expect(
          Dimension.min(10.toPXLength, 5.toVWLength) ==
              Dimension.max(10.toPXLength, 5.toVWLength),
          isFalse);
    });

    test('operand order matters for equality', () {
      expect(
          Dimension.max(10.toPXLength, 5.toVWLength) ==
              Dimension.max(5.toVWLength, 10.toPXLength),
          isFalse);
      expect((1.toPXLength + 2.toVWLength) == (2.toVWLength + 1.toPXLength),
          isFalse);
    });

    test('clamp built the same way is equal', () {
      final Dimension a =
          Dimension.clamp(10.toPXLength, 50.toPercentLength, 100.toVWLength);
      final Dimension b =
          Dimension.clamp(10.toPXLength, 50.toPercentLength, 100.toVWLength);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(<Dimension>{a, b}, hasLength(1));
    });
  });

  group('toString', () {
    test('describes expressions', () {
      expect((10.toPXLength + 5.toVWLength).toString(), '5.0%vw + 10.0px');
      expect(Dimension.max(10.toPXLength, 5.toPercentLength).toString(),
          'max(10.0px, 5.0%)');
      expect(Dimension.min(10.toPXLength, 5.toPercentLength).toString(),
          'min(10.0px, 5.0%)');
      expect(
          Dimension.clamp(10.toPXLength, 5.toPercentLength, 1.toVHLength)
              .toString(),
          'max(10.0px, min(5.0%, 1.0%vh))');
    });
  });
}
