import 'package:flutter_test/flutter_test.dart';

import 'package:dimension/dimension.dart';

void main() {
  test('', () {
    expect((10.toPercentLength - 20.toPXLength).toJson().toString(),
        '[-20.0px, 10.0%]');
    expect(
        (-Dimension.max(10.toPercentLength, 20.toPXLength) - 20.toPXLength)
            .toJson()
            .toString(),
        '[-20.0px, {method: min, value1: -10.0%, value2: -20.0px}]');
  });
}
