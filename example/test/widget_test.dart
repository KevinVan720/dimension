import 'package:dimension/dimension.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the demo animates between the two sizes',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    final Finder box = find.byType(AnimatedDimensionSizedBox);
    final Size before = tester.getSize(box);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final Size after = tester.getSize(box);
    expect(after, isNot(before));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(tester.getSize(box), before);
  });
}
