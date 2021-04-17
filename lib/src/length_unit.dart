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

  ///Aspect Ratio?
  //ar,

  ///no constraint
  //auto,

}

const Map<String, LengthUnit> lengthUnitMap = {
  "\%": LengthUnit.percent,
  "px": LengthUnit.px,
  "vh": LengthUnit.vh,
  "vw": LengthUnit.vw,
  "vmin": LengthUnit.vmin,
  "vmax": LengthUnit.vmax,
};

LengthUnit? parseLengthUnit(String? unit) {
  if (unit == null || unit.trim().length == 0) {
    return null;
  }
  return lengthUnitMap[unit];
}
