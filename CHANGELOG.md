## 0.0.1

Initial release. Introduce Dimension/Length class.

## 0.0.2

Build doc. 

## 0.0.3

Build doc.

## 0.0.4

Update dependence

## 0.0.5

Add vmin, vmax units

## 0.0.6

Fix length lerp bugs

## 0.0.7

Add isAbsolute value

## 0.0.8

Remove a false assert

## 0.0.9

Add isLocal value

## 0.1.0

Remove DynamicEdgeInset, DynamicOffset

## 0.1.1

Update path

## 0.1.2

Code restructure

## 0.1.3

Update dependence

## 0.1.4

Code restructure

## 0.1.5

DimensionSizedBox

## 0.1.6

Update license.

## 0.1.7

Update dependency.

## 0.2.0

Breaking change: Fix: Migrate use of hashValues to Object.hash api which has been the latest standard since Dart 2.14.0

## [0.2.1]

Support the latest Flutter stable (requires Dart 3.6 / Flutter 3.27 or newer).
The package no longer depends on Material and only uses the Flutter widgets layer,
so it works with apps using flutter/material.dart or the standalone material_ui package.

Fixes:
- Adding to or subtracting from a sum no longer modifies the original sum, and a sum can be added to itself.
- Sums that collapse to a single unit (e.g. `1.toPXLength + 2.toPXLength + 3.toPXLength`) no longer throw an assertion error.
- Interpolating between null and a min/max/clamp dimension no longer throws.
- min/max/clamp scale and interpolate correctly with negative factors, so overshooting curves (e.g. `Curves.easeOutBack`) animate correctly.
- DimensionSizedBox updates vw/vh/vmin/vmax values when the screen size changes.
- DimensionSizedBox reports its width as intrinsic width and its height as intrinsic height (they were swapped).
- Length parsing handles exponent notation (`1e-7px`), `Infinity`/`NaN`, numbers without a unit (read as px) and surrounding whitespace.
- parseDimension no longer crashes on a min/max with a missing value or on unparseable list entries, reads numbers as px lengths, and also accepts a JSON encoded string.
- Length.toString no longer throws for infinite or NaN values.
- Repeated interpolation (interrupted animations) no longer nests sums.
