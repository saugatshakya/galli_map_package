import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GalliCircle {
  final double radius;
  final LatLng center;
  final Color color;
  final Color borderColor;
  final double borderStroke;

  GalliCircle(
      {this.color = Colors.white,
      this.borderColor = Colors.black,
      this.borderStroke = 1,
      required this.center,
      required this.radius});

  CircleMarker toCircleMarker() {
    return CircleMarker(
        radius: radius,
        point: center,
        color: color,
        borderColor: borderColor,
        borderStrokeWidth: borderStroke,
        useRadiusInMeter: true);
  }

  bool containsPoint(LatLng point) {
    double distance = Geolocator.distanceBetween(
        point.latitude, point.longitude, center.latitude, center.longitude);
    if (distance > radius) {
      return false;
    } else {
      return true;
    }
  }
}
