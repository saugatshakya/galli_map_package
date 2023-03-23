import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:galli_map/galli_map.dart';

/// A class that represents a marker on a `FlutterMap`.
class GalliMarker {
  /// The location of the marker.
  final LatLng latlng;

  /// The widget to be used as the marker.
  final Widget markerWidget;

  /// The anchor point of the marker. Default is `Anchor.center`.
  final Anchor? anchor;

  /// Creates a new instance of the [GalliMarker] class.
  ///
  /// [latlng] The location of the marker.
  /// [markerWidget] The widget to be used as the marker.
  /// [anchor] The anchor point of the marker. Default is `Anchor.center`.
  const GalliMarker({
    required this.latlng,
    required this.markerWidget,
    this.anchor = Anchor.center,
  });

  /// Converts this instance of the [GalliMarker] class to a [Marker] object.
  Marker toMarker() {
    return Marker(
      point: latlng,
      builder: (_) => markerWidget,
      anchorPos: _getAnchorPos(),
    );
  }

  /// Maps an [Anchor] enum value to its corresponding [AnchorPos] object.
  AnchorPos? _getAnchorPos() {
    switch (anchor) {
      case Anchor.top:
        return AnchorPos.align(AnchorAlign.top);
      case Anchor.center:
        return AnchorPos.align(AnchorAlign.center);
      case Anchor.bottom:
        return AnchorPos.align(AnchorAlign.bottom);
      case Anchor.right:
        return AnchorPos.align(AnchorAlign.right);
      case Anchor.left:
        return AnchorPos.align(AnchorAlign.left);
      case null:
        return null;
    }
  }
}

/// An enum representing the anchor positions of a marker.
enum Anchor {
  top,
  center,
  bottom,
  right,
  left,
}
