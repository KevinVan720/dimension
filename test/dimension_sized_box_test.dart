import 'package:dimension/dimension.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const Key boxKey = Key('box');
const Key childKey = Key('child');

/// Places [child] at the top left of a [parent] sized area, giving it loose
/// constraints of at most [parent], inside a [MediaQuery] of [screen] size.
Widget harness(
  Widget child, {
  Size screen = const Size(400, 800),
  Size parent = const Size(300, 200),
}) {
  return MediaQuery(
    data: MediaQueryData(size: screen),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: parent.width,
        height: parent.height,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('px width and height', (WidgetTester tester) async {
    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: 120.toPXLength,
      height: 80.toPXLength,
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(120, 80));
  });

  testWidgets('percent is relative to the parent constraints',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: 50.toPercentLength,
      height: 25.toPercentLength,
      child: const SizedBox(key: childKey),
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(150, 50));
    expect(tester.getSize(find.byKey(childKey)), const Size(150, 50));
  });

  testWidgets('viewport units are relative to the MediaQuery size',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: 10.toVWLength,
      height: 10.toVHLength,
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(40, 80));

    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: 10.toVMAXLength,
      height: 10.toVMINLength,
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(80, 40));
  });

  testWidgets('expressions', (WidgetTester tester) async {
    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: Dimension.max(20.toPercentLength, 100.toPXLength),
      height: Dimension.clamp(10.toPXLength, 50.toVHLength, 150.toPXLength),
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(100, 150));

    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: 100.toPercentLength - 10.toVWLength,
      height: 50.toPercentLength + 10.toPXLength,
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(260, 110));
  });

  testWidgets('a null dimension passes the parent constraints through',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      height: 50.toPXLength,
      child: const SizedBox(key: childKey, width: 30, height: 40),
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(30, 50));
    expect(tester.getSize(find.byKey(childKey)), const Size(30, 50));

    await tester.pumpWidget(harness(const DimensionSizedBox(key: boxKey)));
    expect(tester.getSize(find.byKey(boxKey)), Size.zero);
  });

  testWidgets('percent in an unbounded parent is relative to the screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness(
      UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: DimensionSizedBox(
          key: boxKey,
          width: 50.toPercentLength,
          height: 25.toPercentLength,
        ),
      ),
      parent: const Size(300, 300),
    ));
    expect(tester.getSize(find.byKey(boxKey)), const Size(200, 200));
  });

  testWidgets('negative sizes are clamped to zero',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: (-10).toPXLength,
      height: 10.toPXLength - 20.toPercentLength,
    )));
    expect(tester.getSize(find.byKey(boxKey)), Size.zero);
  });

  testWidgets('the child gets the exact size even if the parent is smaller',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: 500.toPXLength,
      height: 50.toPXLength,
      child: const SizedBox(key: childKey),
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(300, 50));
    expect(tester.getSize(find.byKey(childKey)), const Size(500, 50));
  });

  testWidgets('updates when the dimensions change',
      (WidgetTester tester) async {
    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: 10.toPXLength,
      height: 10.toPXLength,
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(10, 10));

    await tester.pumpWidget(harness(DimensionSizedBox(
      key: boxKey,
      width: 20.toPercentLength,
      height: 5.toVHLength,
    )));
    expect(tester.getSize(find.byKey(boxKey)), const Size(60, 40));
  });

  testWidgets('updates when the screen size changes',
      (WidgetTester tester) async {
    final Widget box = DimensionSizedBox(
      key: boxKey,
      width: 10.toVWLength,
      height: 10.toVHLength,
    );
    await tester.pumpWidget(harness(box));
    expect(tester.getSize(find.byKey(boxKey)), const Size(40, 80));

    await tester.pumpWidget(harness(box, screen: const Size(800, 400)));
    expect(tester.getSize(find.byKey(boxKey)), const Size(80, 40));
    expect(
        tester
            .renderObject<RenderDimensionSizedBox>(find.byKey(boxKey))
            .screenSize,
        const Size(800, 400));
  });

  testWidgets('uses the size of the View when there is no explicit MediaQuery',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(Align(
      alignment: Alignment.topLeft,
      child: DimensionSizedBox(
        key: boxKey,
        width: 10.toVWLength,
        height: 10.toVHLength,
      ),
    ));
    expect(tester.getSize(find.byKey(boxKey)), const Size(100, 50));
  });

  group('intrinsic dimensions', () {
    testWidgets(
        'use the width for intrinsic widths and the height for '
        'intrinsic heights', (WidgetTester tester) async {
      await tester.pumpWidget(harness(DimensionSizedBox(
        key: boxKey,
        width: 100.toPXLength,
        height: 50.toPXLength,
      )));
      final RenderBox box = tester.renderObject<RenderBox>(find.byKey(boxKey));
      expect(box.getMinIntrinsicWidth(double.infinity), 100);
      expect(box.getMaxIntrinsicWidth(double.infinity), 100);
      expect(box.getMinIntrinsicHeight(double.infinity), 50);
      expect(box.getMaxIntrinsicHeight(double.infinity), 50);
    });

    testWidgets('relative units resolve against the screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness(DimensionSizedBox(
        key: boxKey,
        width: 50.toPercentLength,
        height: 10.toVHLength,
      )));
      final RenderBox box = tester.renderObject<RenderBox>(find.byKey(boxKey));
      expect(box.getMinIntrinsicWidth(double.infinity), 200);
      expect(box.getMaxIntrinsicWidth(100), 200);
      expect(box.getMinIntrinsicHeight(double.infinity), 80);
      expect(box.getMaxIntrinsicHeight(100), 80);
    });

    testWidgets('fall back to the child', (WidgetTester tester) async {
      await tester.pumpWidget(harness(const DimensionSizedBox(
        key: boxKey,
        child: SizedBox(width: 30, height: 40),
      )));
      final RenderBox box = tester.renderObject<RenderBox>(find.byKey(boxKey));
      expect(box.getMinIntrinsicWidth(double.infinity), 30);
      expect(box.getMaxIntrinsicWidth(double.infinity), 30);
      expect(box.getMinIntrinsicHeight(double.infinity), 40);
      expect(box.getMaxIntrinsicHeight(double.infinity), 40);

      await tester.pumpWidget(harness(const DimensionSizedBox(key: boxKey)));
      final RenderBox empty =
          tester.renderObject<RenderBox>(find.byKey(boxKey));
      expect(empty.getMinIntrinsicWidth(double.infinity), 0);
      expect(empty.getMaxIntrinsicHeight(double.infinity), 0);
    });

    testWidgets('work inside IntrinsicWidth / IntrinsicHeight',
        (WidgetTester tester) async {
      await tester.pumpWidget(harness(IntrinsicHeight(
        child: IntrinsicWidth(
          child: DimensionSizedBox(
            key: boxKey,
            width: 100.toPXLength,
            height: 50.toPXLength,
          ),
        ),
      )));
      expect(tester.getSize(find.byKey(boxKey)), const Size(100, 50));
    });
  });

  testWidgets('dry layout matches the actual layout',
      (WidgetTester tester) async {
    final List<Widget> boxes = <Widget>[
      DimensionSizedBox(
          key: boxKey, width: 50.toPercentLength, height: 10.toVHLength),
      DimensionSizedBox(
        key: boxKey,
        width: 500.toPXLength,
        child: const SizedBox(width: 30, height: 40),
      ),
      const DimensionSizedBox(key: boxKey),
    ];
    for (final Widget box in boxes) {
      await tester.pumpWidget(harness(box));
      final RenderBox renderBox =
          tester.renderObject<RenderBox>(find.byKey(boxKey));
      expect(renderBox.getDryLayout(renderBox.constraints), renderBox.size);
    }
  });

  test('RenderDimensionSizedBox exposes its configuration', () {
    final RenderDimensionSizedBox box = RenderDimensionSizedBox(
      width: 10.toPXLength,
      height: 20.toVHLength,
      screenSize: const Size(100, 200),
    );
    expect(box.width, 10.toPXLength);
    expect(box.height, 20.toVHLength);
    expect(box.screenSize, const Size(100, 200));

    box
      ..width = null
      ..height = 5.toPXLength
      ..screenSize = const Size(1, 2);
    expect(box.width, isNull);
    expect(box.height, 5.toPXLength);
    expect(box.screenSize, const Size(1, 2));

    box.layout(const BoxConstraints(maxWidth: 50, maxHeight: 50));
    expect(box.size, const Size(0, 5));
  });
}
