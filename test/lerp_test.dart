import 'package:dimension/dimension.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const Size screen = Size(400, 800);
const double constraint = 200;

double px(Dimension dimension) =>
    dimension.toPX(constraint: constraint, screenSize: screen);

/// Recursively checks that a serialized dimension contains no nested lists
/// directly inside a list (i.e. sums are flattened).
bool isFlatSum(dynamic json) {
  if (json is List) {
    return json.every((dynamic e) => e is! List && isFlatSum(e));
  }
  if (json is Map) {
    return isFlatSum(json['value1']) && isFlatSum(json['value2']);
  }
  return true;
}

void main() {
  group('Dimension.lerp between lengths', () {
    test('same unit gives a single Length', () {
      expect(Dimension.lerp(10.toPXLength, 20.toPXLength, 0.25),
          const Length(12.5));
      expect(Dimension.lerp(10.toVWLength, 20.toVWLength, 0.5),
          const Length(15, unit: LengthUnit.vw));
    });

    test('endpoints', () {
      expect(Dimension.lerp(10.toPXLength, 20.toPXLength, 0), 10.toPXLength);
      expect(Dimension.lerp(10.toPXLength, 20.toPXLength, 1), 20.toPXLength);
    });

    test('different units interpolate their px values', () {
      final Dimension a = 100.toPXLength;
      final Dimension b = 50.toVWLength; // 200px
      expect(px(Dimension.lerp(a, b, 0)!), 100.0);
      expect(px(Dimension.lerp(a, b, 0.5)!), 150.0);
      expect(px(Dimension.lerp(a, b, 1)!), 200.0);
      expect(Dimension.lerp(a, b, 0.5)!.toJson(), <String>['50.0px', '25.0vw']);
    });

    test('vmin and vmax are kept apart', () {
      final Dimension a = 10.toVMINLength; // 40px
      final Dimension b = 10.toVMAXLength; // 80px
      expect(px(Dimension.lerp(a, b, 0.5)!), 60.0);
    });

    test('null is treated as zero', () {
      expect(Dimension.lerp(null, 20.toPXLength, 0.25), const Length(5));
      expect(Dimension.lerp(20.toPXLength, null, 0.25), const Length(15));
      expect(Dimension.lerp(null, null, 0.5), isNull);
    });
  });

  group('Dimension.lerp with expressions', () {
    test('between a sum and a length', () {
      final Dimension sum = 10.toPXLength + 5.toVWLength; // 30px
      expect(px(Dimension.lerp(sum, 50.toPercentLength, 0.5)!), 65.0);
      expect(px(Dimension.lerp(50.toPercentLength, sum, 0.5)!), 65.0);
    });

    test('between two sums', () {
      final Dimension a = 10.toPXLength + 5.toVWLength; // 30px
      final Dimension b = 20.toPercentLength - 5.toVHLength; // 0px
      expect(px(Dimension.lerp(a, b, 0.25)!), 22.5);
    });

    test('with min/max endpoints', () {
      final Dimension max = Dimension.max(10.toPXLength, 50.toPercentLength);
      expect(px(Dimension.lerp(0.toPXLength, max, 0.5)!), 50.0);
      expect(px(Dimension.lerp(max, 0.toPXLength, 0.25)!), 75.0);
    });

    test('with a null endpoint and a min/max', () {
      final Dimension max = Dimension.max(10.toPXLength, 50.toPercentLength);
      expect(px(Dimension.lerp(null, max, 0.5)!), 50.0);
      expect(px(Dimension.lerp(max, null, 0.5)!), 50.0);
      expect(Dimension.lerp(null, max, 0.5), max.scale(0.5));
      expect(Dimension.lerp(max, null, 0.25), max.scale(0.75));
    });

    test('with a sum whose parts all share one unit', () {
      final Dimension sum = 1.toPXLength + 2.toPXLength;
      expect(px(Dimension.lerp(null, sum, 0.5)!), 1.5);
      expect(px(Dimension.lerp(sum, null, 0.5)!), 1.5);
      expect(px(Dimension.lerp(10.toPXLength, sum, 0.5)!), 6.5);
      expect(px(Dimension.lerp(sum, 10.toPXLength, 0.5)!), 6.5);
    });

    test('outside of [0, 1] (overshooting curves)', () {
      final Dimension max = Dimension.max(100.toPXLength, 10.toPercentLength);
      expect(px(Dimension.lerp(max, 200.toPXLength, 1.1)!), closeTo(210, 1e-9));
      final Dimension min = Dimension.min(100.toPXLength, 300.toPercentLength);
      expect(
          px(Dimension.lerp(200.toPXLength, min, -0.2)!), closeTo(220, 1e-9));
    });

    test('interpolates px values linearly for any combination', () {
      final List<Dimension?> values = <Dimension?>[
        null,
        100.toPXLength,
        50.toPercentLength,
        10.toVWLength,
        10.toVMINLength,
        10.toPXLength + 5.toVWLength,
        1.toPXLength + 2.toPXLength,
        Dimension.max(10.toPXLength, 50.toPercentLength),
        Dimension.min(10.toPXLength, 50.toPercentLength),
        Dimension.clamp(10.toPXLength, 25.toVMAXLength, 150.toPXLength),
        -Dimension.max(10.toPXLength, 50.toPercentLength),
      ];
      const List<double> ts = <double>[-0.5, 0, 0.3, 0.5, 1, 1.5];
      for (final Dimension? a in values) {
        for (final Dimension? b in values) {
          for (final double t in ts) {
            final Dimension? result = Dimension.lerp(a, b, t);
            if (a == null && b == null) {
              expect(result, isNull);
              continue;
            }
            final double expected =
                (a == null ? 0 : px(a)) * (1 - t) + (b == null ? 0 : px(b)) * t;
            expect(px(result!), closeTo(expected, 1e-9),
                reason: 'lerp($a, $b, $t)');
          }
        }
      }
    });

    test('repeated interpolation keeps sums flat', () {
      Dimension current = 100.toPXLength;
      final List<Dimension> targets = <Dimension>[
        50.toVWLength,
        10.toPXLength + 5.toVHLength,
        Dimension.max(10.toPXLength, 50.toPercentLength),
        20.toPercentLength,
      ];
      double expected = px(current);
      for (int i = 0; i < 12; i++) {
        final Dimension target = targets[i % targets.length];
        current = Dimension.lerp(current, target, 0.5)!;
        expected = expected * 0.5 + px(target) * 0.5;
        expect(px(current), closeTo(expected, 1e-9));
        expect(isFlatSum(current.toJson()), isTrue,
            reason: current.toJson().toString());
      }
    });
  });

  group('DimensionTween', () {
    test('stores begin and end', () {
      final DimensionTween tween =
          DimensionTween(begin: 10.toPXLength, end: 20.toVWLength);
      expect(tween.begin, 10.toPXLength);
      expect(tween.end, 20.toVWLength);
    });

    test('returns begin/end at t = 0/1', () {
      final Dimension begin = 10.toPXLength + 1.toVWLength;
      final Dimension end = Dimension.max(1.toPXLength, 1.toPercentLength);
      final DimensionTween tween = DimensionTween(begin: begin, end: end);
      expect(identical(tween.transform(0), begin), isTrue);
      expect(identical(tween.transform(1), end), isTrue);
    });

    test('interpolates in between', () {
      final DimensionTween tween =
          DimensionTween(begin: 10.toPXLength, end: 20.toPXLength);
      expect(tween.lerp(0.5), 15.toPXLength);
      expect(tween.transform(0.5), 15.toPXLength);
      expect(tween.evaluate(const AlwaysStoppedAnimation<double>(0.5)),
          15.toPXLength);

      final DimensionTween mixed =
          DimensionTween(begin: 10.toPXLength, end: 50.toPercentLength);
      expect(px(mixed.transform(0.5)!), 55.0);
    });

    test('handles null begin or end', () {
      expect(DimensionTween(end: 20.toPXLength).transform(0.5), 10.toPXLength);
      expect(
          DimensionTween(begin: 20.toPXLength).transform(0.25), 15.toPXLength);
      expect(DimensionTween().transform(0.5), isNull);
      expect(
          px(DimensionTween(
                  end: Dimension.min(20.toPXLength, 50.toPercentLength))
              .transform(0.5)!),
          10.0);
    });
  });
}
