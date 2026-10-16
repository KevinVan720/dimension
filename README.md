# dimension

A Flutter package that introduce the Dimension/Length class.
It mimics the css length system and currently supports six units: px, percentage, vw, vh, vmin, and vmax. The
user would need to supply the constraint value and the screen size in order to get a px value
from the Length class.

You can also add/subtract multiple Length, or use min, max, clamp functions on them. See the example
app. The Dimension class also supports tweening.

Having a length class in Flutter can ease the process of creating responsive apps. Also, all the classes
in this package can be serialized and deserialized.

## Getting Started

Create a Dimension instance:

```dart
var length=Length(10.0, unit: LengthUnit.percent);
```

Get the actual px value by calling:

```dart
double px=length.toPX(constraint: 100, screenSize: MediaQuery.sizeOf(context));
```

where the constraint you can get from the parent BoxConstraint and the screenSize you can get with
MediaQuery.

You can also create a Length instance from numbers. For example:

```dart
length=10.toPXLength; //10 px
length=10.toPercentLength; // 10% of the parent constrant
length=10.toVWLength; //10% of the screen width
length=10.toVHLength; //10% of the screen height
length=10.toVMINLength; //10% of the shorter side of the screen
length=10.toVMAXLength; //10% of the longer side of the screen
```

You can also add or subtract Length:

```dart
length=100.toVWLength - 10.toPXLength + 20.toPercentLength;
```

or use min(), max() or clamp() on them:
```dart
length=Dimension.max(100.toPXLength, 10.toVWLength);
length=Dimension.clamp(10.toVWLength, 100.toPXLength, 20.toPercentLength);
```

and those operations can be nested and combined.

## DimensionSizedBox

You can manually call the toPX() function on a dimension and provide the constraint and the
screen size and get a px value. Or you can use the DimensionSizedBox:
```dart
const DimensionSizedBox({
    super.key,
    this.width,
    this.height,
    super.child,
  });

  final Dimension? width;
  final Dimension? height;
```
which is similar to SizedBox but accepts two Dimension instances. The screen size is read from
`MediaQuery.sizeOf(context)`, so the box updates when the screen size changes. The package only
depends on the Flutter widgets layer, not on Material.

Notice if for example this widget has a unbound parent maxWidth and the width parameter depends on the parent (has a percent unit), the parent maxWidth will be clamped to the width of the screen. This ensures that this Box is always bounded unless you use something like Length(double.infinity).

Use AnimatedDimensionSizedBox to animate between two dimensions, even if they use different units:
```dart
AnimatedDimensionSizedBox(
  duration: const Duration(seconds: 1),
  width: toggle ? 50.toPercentLength : Dimension.max(200.toPXLength, 20.toVWLength),
  height: 100.toPXLength,
  child: child,
)
```

## Serialization

Any dimension instance can be serialized/deserializad.

```dart
String jsonStr=json.encode(length.toJson());
```

Then get back the dimension by calling:
```dart
Dimension? newLength=parseDimension(json.decode(jsonStr));
```
`parseDimension` also accepts the encoded `jsonStr` itself, and returns null for input that is not a dimension.

See the example app for a real world application of this package.
