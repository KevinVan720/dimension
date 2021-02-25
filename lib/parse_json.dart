import 'dimension.dart';
import 'dynamic_edge_insets.dart';
import 'dynamic_offset.dart';

Length? parseLength(String? string) {
  return Length.fromJson(string);
}

DynamicOffset? parseDynamicOffset(Map<String, dynamic>? map) {
  if (map == null) return null;
  Dimension dx = parseDimension(map['dx']) ?? Length(0);
  Dimension dy = parseDimension(map['dy']) ?? Length(0);
  return DynamicOffset(dx, dy);
}

DynamicEdgeInsets? parseDynamicEdgeInsets(Map<String, dynamic>? map) {
  if (map == null) return null;
  Dimension? top = parseDimension(map['top']);
  Dimension? bottom = parseDimension(map['bottom']);
  Dimension? left = parseDimension(map['left']);
  Dimension? right = parseDimension(map['right']);
  return DynamicEdgeInsets.only(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
  );
}
