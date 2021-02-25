# dimension

A Flutter package that introduce the Dimension/Length class.
It mimics the css length system and currently supports four unit including px, percentage, vw and vh. The
user would need to supply the constraint length and the screen size in order to get a px value
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

where the constraintSize you can get by using the LayoutBuilder and the screenSize you can get with
MediaQuery.

You can also create Length instance from numbers. For example:

```dart
length=10.toPXLength; //10 px
length=10.toPercentLength; // 10% of the constrant
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

and those operations can be nested or combined.

## Serialization

Any dimension instance can be serialized/deserializad.

```dart
String jsonStr=json.encode(length.toJson());
```

Then get back the dimension by calling:
```
Dimension newLength=parseDimension(jsonStr);
```




