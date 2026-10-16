import 'dart:convert';

import 'package:dimension/dimension.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const Size screen = Size(400, 800);
const double constraint = 200;

double px(Dimension dimension) =>
    dimension.toPX(constraint: constraint, screenSize: screen);

Dimension? roundTrip(Dimension dimension) =>
    parseDimension(json.decode(json.encode(dimension.toJson())));

void main() {
  group('toJson format', () {
    test('Length serializes to "<value><unit>"', () {
      expect(const Length(10).toJson(), '10.0px');
      expect(const Length(12.5, unit: LengthUnit.percent).toJson(), '12.5%');
      expect(const Length(100, unit: LengthUnit.vw).toJson(), '100.0vw');
      expect(const Length(-3, unit: LengthUnit.vh).toJson(), '-3.0vh');
      expect(const Length(5, unit: LengthUnit.vmin).toJson(), '5.0vmin');
      expect(const Length(5, unit: LengthUnit.vmax).toJson(), '5.0vmax');
      expect(const Length(0.1).toJson(), '0.1px');
      expect(const Length(1e-7).toJson(), '1e-7px');
      expect(const Length(double.infinity).toJson(), 'Infinitypx');
    });

    test('sums serialize to a list', () {
      expect(
          json.encode(
              (100.toVWLength - 10.toPXLength + 20.toPercentLength).toJson()),
          '["-10.0px","100.0vw","20.0%"]');
    });

    test('min/max/clamp serialize to a map with a method', () {
      expect(
          json.encode(
              Dimension.max(20.toPercentLength, 700.toPXLength).toJson()),
          '{"method":"max","value1":"20.0%","value2":"700.0px"}');
      expect(
          json.encode(
              Dimension.min(20.toPercentLength, 700.toPXLength).toJson()),
          '{"method":"min","value1":"20.0%","value2":"700.0px"}');
      expect(
          json.encode(
              Dimension.clamp(200.toPXLength, 40.toVWLength, 200.toPXLength)
                  .toJson()),
          '{"method":"max","value1":"200.0px",'
          '"value2":{"method":"min","value1":"40.0vw","value2":"200.0px"}}');
    });

    test('nested expressions', () {
      final Dimension value = 50.toVHLength +
          10.toPercentLength -
          Dimension.min(4.toPercentLength, 40.toPXLength);
      expect(
          json.encode(value.toJson()),
          '["10.0%","50.0vh",'
          '{"method":"max","value1":"-4.0%","value2":"-40.0px"}]');
    });
  });

  group('round trips', () {
    final Map<String, Dimension> dimensions = <String, Dimension>{
      'px': 10.toPXLength,
      'percent': 12.5.toPercentLength,
      'vw': 100.toVWLength,
      'vh': (-3).toVHLength,
      'vmin': 5.toVMINLength,
      'vmax': 5.toVMAXLength,
      'fraction': (1 / 3).toPXLength,
      'tiny': 1e-7.toPXLength,
      'huge': 1e21.toVWLength,
      'negative tiny': (-5.551115123125783e-17).toPercentLength,
      'infinity': double.infinity.toPXLength,
      'negative infinity': double.negativeInfinity.toVHLength,
      'sum': 100.toVWLength - 10.toPXLength + 20.toPercentLength,
      'same unit sum': 1.toPXLength + 2.toPXLength,
      'max': Dimension.max(20.toPercentLength, 700.toPXLength),
      'min': Dimension.min(20.toPercentLength, 700.toPXLength),
      'clamp':
          Dimension.clamp(10.toPXLength, 50.toPercentLength, 100.toVWLength),
      'nested': 50.toVHLength +
          10.toPercentLength -
          Dimension.min(4.toPercentLength, 40.toPXLength),
      'lerped': Dimension.lerp(10.toPXLength + 5.toVWLength,
          Dimension.max(10.toPXLength, 50.toPercentLength), 0.3)!,
    };

    dimensions.forEach((String name, Dimension dimension) {
      test(name, () {
        final Dimension? parsed = roundTrip(dimension);
        expect(parsed, dimension);
        expect(parsed.hashCode, dimension.hashCode);
        expect(parsed!.toJson(), dimension.toJson());
        expect(px(parsed), px(dimension));
        expect(parsed.isAbsolute, dimension.isAbsolute);
        expect(parsed.isLocal, dimension.isLocal);
      });
    });

    test('NaN', () {
      final Length parsed =
          roundTrip(const Length(double.nan, unit: LengthUnit.vw))! as Length;
      expect(parsed.value.isNaN, isTrue);
      expect(parsed.unit, LengthUnit.vw);
    });
  });

  group('parsing JSON stored by previous versions', () {
    test('lengths', () {
      expect(parseDimension('10.0px'), const Length(10));
      expect(parseDimension('12.5%'),
          const Length(12.5, unit: LengthUnit.percent));
      expect(parseDimension('100.0vw'), const Length(100, unit: LengthUnit.vw));
      expect(parseDimension('-3.0vh'), const Length(-3, unit: LengthUnit.vh));
      expect(parseDimension('5.0vmin'), const Length(5, unit: LengthUnit.vmin));
      expect(parseDimension('5.0vmax'), const Length(5, unit: LengthUnit.vmax));
    });

    test('expressions', () {
      final Dimension sum =
          parseDimension(json.decode('["-10.0px","100.0vw","20.0%"]'))!;
      expect(sum, 100.toVWLength - 10.toPXLength + 20.toPercentLength);
      expect(px(sum), 430.0);

      final Dimension clamp = parseDimension(json.decode(
          '{"method":"max","value1":"200.0px",'
          '"value2":{"method":"min","value1":"40.0vw","value2":"200.0px"}}'))!;
      expect(clamp,
          Dimension.clamp(200.toPXLength, 40.toVWLength, 200.toPXLength));
      expect(px(clamp), 200.0);

      final Dimension nested = parseDimension(json.decode('["10.0%","50.0vh",'
          '{"method":"max","value1":"-4.0%","value2":"-40.0px"}]'))!;
      expect(px(nested), 412.0);
    });

    test('nested sums produced by interpolation', () {
      final Dimension nested = parseDimension(json.decode(
          '[["5.0px","2.5vw"],"10.0px",{"method":"min","value1":"1.0px","value2":"2.0px"}]'))!;
      expect(px(nested), 5 + 10 + 10 + 1.0);
    });

    test('single element sums (written by release builds)', () {
      expect(parseDimension(<dynamic>['6.0px']), const Length(6));
      expect(px(parseDimension(json.decode('["6.0px"]'))!), 6.0);
    });

    test('maps that are not Map<String, dynamic>', () {
      expect(
          parseDimension(<dynamic, dynamic>{
            'method': 'min',
            'value1': '1.0px',
            'value2': '2.0px',
          }),
          Dimension.min(1.toPXLength, 2.toPXLength));
    });
  });

  group('Length.fromJson / parseLength', () {
    test('null gives null', () {
      expect(Length.fromJson(null), isNull);
      expect(parseLength(null), isNull);
    });

    test('values without decimals and surrounding whitespace', () {
      expect(Length.fromJson('10px'), const Length(10));
      expect(
          Length.fromJson('10%'), const Length(10, unit: LengthUnit.percent));
      expect(Length.fromJson(' 10 px'), const Length(10));
      expect(Length.fromJson('10vw '), const Length(10, unit: LengthUnit.vw));
      expect(Length.fromJson('+2.5vh'), const Length(2.5, unit: LengthUnit.vh));
      expect(
          Length.fromJson('.5vmax'), const Length(0.5, unit: LengthUnit.vmax));
      expect(parseLength('3vmin'), const Length(3, unit: LengthUnit.vmin));
    });

    test('exponent notation', () {
      expect(Length.fromJson('1e-7px'), const Length(1e-7));
      expect(
          Length.fromJson('1e+21vw'), const Length(1e21, unit: LengthUnit.vw));
      expect(Length.fromJson('2.5E3%'),
          const Length(2500, unit: LengthUnit.percent));
    });

    test('non-finite values', () {
      expect(Length.fromJson('Infinitypx'), const Length(double.infinity));
      expect(Length.fromJson('-Infinity%'),
          const Length(double.negativeInfinity, unit: LengthUnit.percent));
      final Length nan = Length.fromJson('NaNvw')!;
      expect(nan.value.isNaN, isTrue);
      expect(nan.unit, LengthUnit.vw);
    });

    test('a number without unit is px', () {
      expect(Length.fromJson('10'), const Length(10));
      expect(Length.fromJson('-2.5'), const Length(-2.5));
    });

    test('unknown units fall back to px', () {
      expect(Length.fromJson('10em'), const Length(10));
      expect(Length.fromJson('10PX'), const Length(10));
      expect(Length.fromJson('10.0%vw'), const Length(10));
    });

    test('unparseable input gives zero', () {
      expect(Length.fromJson(''), const Length(0));
      expect(Length.fromJson('   '), const Length(0));
      expect(Length.fromJson('px'), const Length(0));
      expect(Length.fromJson('vw'), const Length(0, unit: LengthUnit.vw));
      expect(Length.fromJson('abc'), const Length(0));
    });
  });

  group('parseDimension edge cases', () {
    test('null and unsupported input give null', () {
      expect(parseDimension(null), isNull);
      expect(parseDimension(true), isNull);
      expect(parseDimension(<String, dynamic>{}), isNull);
      expect(
          parseDimension(<String, dynamic>{
            'method': 'avg',
            'value1': '1px',
            'value2': '2px',
          }),
          isNull);
    });

    test('numbers are px lengths', () {
      expect(parseDimension(10), const Length(10));
      expect(parseDimension(2.5), const Length(2.5));
      expect(parseDimension(<dynamic>[10, '5.0vw']),
          parseDimension(<dynamic>['10.0px', '5.0vw']));
      expect(
          parseDimension(<String, dynamic>{
            'method': 'max',
            'value1': 1,
            'value2': 2.0,
          }),
          Dimension.max(1.toPXLength, 2.toPXLength));
    });

    test('a min/max with one missing value is that value', () {
      expect(
          parseDimension(<String, dynamic>{'method': 'max', 'value1': '1px'}),
          const Length(1));
      expect(
          parseDimension(<String, dynamic>{'method': 'min', 'value2': '2px'}),
          const Length(2));
      expect(
          parseDimension(<String, dynamic>{
            'method': 'min',
            'value1': '1px',
            'value2': null,
          }),
          const Length(1));
      expect(parseDimension(<String, dynamic>{'method': 'min'}), isNull);
    });

    test('unparseable list entries are skipped', () {
      expect(parseDimension(<dynamic>['1px', true, '2vw']),
          parseDimension(<dynamic>['1px', '2vw']));
      expect(parseDimension(<dynamic>['1px', null]), const Length(1));
      expect(parseDimension(<dynamic>[]), const Length(0));
    });

    test('accepts a JSON encoded string', () {
      final Dimension clamp =
          Dimension.clamp(10.toPXLength, 50.toPercentLength, 100.toVWLength);
      expect(parseDimension(json.encode(clamp.toJson())), clamp);
      final Dimension sum = 1.toPXLength + 2.toVWLength;
      expect(parseDimension(json.encode(sum.toJson())), sum);
      expect(
          parseDimension(json.encode(10.toVWLength.toJson())), 10.toVWLength);
      expect(parseDimension(' [ "2vw" , "1px" ] '), sum);
    });

    test('malformed JSON-like strings fall back to length parsing', () {
      expect(parseDimension('[1px'), const Length(0));
      expect(parseDimension('{'), const Length(0));
    });
  });
}
