import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GalliLine {
  final List<LatLng> line;
  final Color lineColor;
  final Color borderColor;
  final double lineStroke;
  final double borderStroke;
  GalliLine(
      {this.lineColor = Colors.white,
      this.borderColor = Colors.black,
      this.lineStroke = 4,
      this.borderStroke = 1,
      required this.line});
  Polyline toPolyline() {
    return Polyline(
        points: line,
        color: lineColor,
        borderColor: borderColor,
        borderStrokeWidth: borderStroke,
        strokeWidth: lineStroke);
  }
}
