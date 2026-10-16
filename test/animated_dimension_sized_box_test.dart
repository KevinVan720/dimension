import 'package:dimension/dimension.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const Key boxKey = Key('box');
const Duration duration = Duration(seconds: 1);

/// Places [child] in a 300x200 area with loose constraints inside a
/// 400x800 screen.
Widget harness(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(size: Size(400, 800)),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 300,
        height: 200,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
}

Widget animatedBox({
  Dimension? width,
  Dimension? height,
  Curve curve = Curves.linear,
  VoidCallback? onEnd,
  Widget? child,
}) {
  return harness(AnimatedDimensionSizedBox(
    key: boxKey,
    width: width,
    height: height,
    curve: curve,
    duration: duration,
    onEnd: onEnd,
    child: child,
  ));
}

void main() {
  testWidgets('starts at the target size', (WidgetTester tester) async {
    await tester.pumpWidget(
        animatedBox(width: 100.toPXLength, height: 50.toPercentLength));
    expect(tester.getSize(find.byKey(boxKey)), const Size(100, 100));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('animates between lengths of the same unit',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(animatedBox(width: 100.toPXLength, height: 20.toPXLength));
    await tester
        .pumpWidget(animatedBox(width: 200.toPXLength, height: 40.toPXLength));
    expect(tester.getSize(find.byKey(boxKey)), const Size(100, 20));

    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getSize(find.byKey(boxKey)), const Size(150, 30));

    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getSize(find.byKey(boxKey)), const Size(200, 40));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(boxKey)), const Size(200, 40));
  });

  testWidgets('animates between different units and expressions',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(animatedBox(width: 100.toPXLength, height: 0.toPXLength));
    await tester.pumpWidget(animatedBox(
      width: 50.toPercentLength, // 150px
      height: Dimension.max(50.toPercentLength, 10.toVHLength), // 100px
    ));

    await tester.pump(const Duration(milliseconds: 250));
    final Size quarter = tester.getSize(find.byKey(boxKey));
    expect(quarter.width, moreOrLessEquals(112.5));
    expect(quarter.height, moreOrLessEquals(25));

    await tester.pump(const Duration(milliseconds: 250));
    final Size half = tester.getSize(find.byKey(boxKey));
    expect(half.width, moreOrLessEquals(125));
    expect(half.height, moreOrLessEquals(50));

    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(boxKey)), const Size(150, 100));
  });

  testWidgets('applies the curve', (WidgetTester tester) async {
    await tester.pumpWidget(animatedBox(width: 0.toPXLength));
    await tester
        .pumpWidget(animatedBox(width: 100.toPXLength, curve: Curves.easeIn));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getSize(find.byKey(boxKey)).width,
        moreOrLessEquals(100 * Curves.easeIn.transform(0.5)));
  });

  testWidgets('overshooting curves work with min/max',
      (WidgetTester tester) async {
    final Dimension begin =
        Dimension.max(100.toPXLength, 10.toPercentLength); // 100px
    await tester.pumpWidget(animatedBox(width: begin));
    await tester.pumpWidget(
        animatedBox(width: 200.toPXLength, curve: Curves.easeOutBack));
    for (int ms = 100; ms <= 900; ms += 100) {
      await tester.pump(const Duration(milliseconds: 100));
      final double t = Curves.easeOutBack.transform(ms / 1000);
      expect(tester.getSize(find.byKey(boxKey)).width,
          moreOrLessEquals(100 + 100 * t),
          reason: 'at $ms ms');
    }
  });

  testWidgets('calls onEnd when the animation completes',
      (WidgetTester tester) async {
    int ended = 0;
    void onEnd() => ended++;
    await tester.pumpWidget(animatedBox(width: 10.toPXLength, onEnd: onEnd));
    await tester.pumpWidget(animatedBox(width: 20.toPXLength, onEnd: onEnd));
    await tester.pump(const Duration(milliseconds: 500));
    expect(ended, 0);
    await tester.pumpAndSettle();
    expect(ended, 1);
  });

  testWidgets('continues from the current size when interrupted',
      (WidgetTester tester) async {
    await tester.pumpWidget(animatedBox(width: 100.toPXLength));
    await tester.pumpWidget(animatedBox(width: 200.toPXLength));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getSize(find.byKey(boxKey)).width, 150);

    await tester.pumpWidget(animatedBox(width: 10.toVWLength)); // 40px
    expect(tester.getSize(find.byKey(boxKey)).width, 150);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getSize(find.byKey(boxKey)).width, moreOrLessEquals(95));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getSize(find.byKey(boxKey)).width, moreOrLessEquals(40));
  });

  testWidgets('an equal target does not restart the animation',
      (WidgetTester tester) async {
    await tester.pumpWidget(animatedBox(
        width:
            Dimension.max(10.toPercentLength, 20.toPXLength) + 5.toVWLength));
    await tester.pumpWidget(animatedBox(
        width:
            Dimension.max(10.toPercentLength, 20.toPXLength) + 5.toVWLength));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.getSize(find.byKey(boxKey)).width, 50);
  });

  testWidgets('a null dimension uses the parent constraints and jumps',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        animatedBox(height: 10.toPXLength, child: const SizedBox(width: 30)));
    expect(tester.getSize(find.byKey(boxKey)), const Size(30, 10));

    await tester.pumpWidget(animatedBox(
        width: 100.toPXLength,
        height: 10.toPXLength,
        child: const SizedBox(width: 30)));
    expect(tester.getSize(find.byKey(boxKey)), const Size(100, 10));
  });

  testWidgets('can be const', (WidgetTester tester) async {
    await tester.pumpWidget(harness(const AnimatedDimensionSizedBox(
      key: boxKey,
      width: Length(12),
      height: Length(50, unit: LengthUnit.percent),
      duration: duration,
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(12, 100));
  });
}
