# dimension

A Flutter package that introduce the Dimension/Length class.
It mimics the css length system and currently supports four units including px, percentage, vw, vh, vmin, and vmax. The
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
double px=length.toPX(constraint: 100, screenSize: MediaQuery.of(context).size);
```

where the constraint you can get from the parent BoxConstraint and the screenSize you can get with
MediaQuery.

You can also create a Length instance from numbers. For example:

```dart
length=10.toPXLength; //10 px
length=10.toPercentLength; // 10% of the parent constrant
length=10.toVWLength; //10% of the screen width
length=10.toVHLength; //10% of the screen height
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
    Key? key,
    this.width,
    this.height,
    Widget? child,
  }) : super(key: key, child: child);

  final Dimension? width;
  final Dimension? height;
```
which is similar to SizedBox but accepts two Dimension instances.

Notice if for example this widget has a unbound parent maxWidth and the width parameter depends on the parent (has a percent unit), the parent maxWidth will be clamped to the width of the screen. This ensures that this Box is always bounded unless you use something like Length(double.infinite).

## Serialization

Any dimension instance can be serialized/deserializad.

```dart
String jsonStr=json.encode(length.toJson());
```

Then get back the dimension by calling:
```
Dimension newLength=parseDimension(jsonStr);
```

See the example app for a real world application of this package.




