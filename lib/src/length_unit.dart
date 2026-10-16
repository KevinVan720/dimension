/// The CSS-like unit of a `Length`.
enum LengthUnit {
  ///logic pixel
  px,

  ///percent of the parent size
  percent,

  ///percent of the screen width
  vw,

  ///percent of the screen height
  vh,

  ///percent of the screen shortest side
  vmin,

  ///percent of the screen longest side
  vmax,
}

/// The serialized symbol of each [LengthUnit].
const Map<String, LengthUnit> lengthUnitMap = {
  '%': LengthUnit.percent,
  'px': LengthUnit.px,
  'vh': LengthUnit.vh,
  'vw': LengthUnit.vw,
  'vmin': LengthUnit.vmin,
  'vmax': LengthUnit.vmax,
};

/// Returns the [LengthUnit] for a symbol of [lengthUnitMap], ignoring
/// surrounding whitespace, or null if [unit] is null or unknown.
LengthUnit? parseLengthUnit(String? unit) {
  if (unit == null) return null;
  return lengthUnitMap[unit.trim()];
}
