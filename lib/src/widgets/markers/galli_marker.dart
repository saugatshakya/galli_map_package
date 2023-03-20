import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GalliMarker {
  final LatLng latlng;
  final Widget markerWidget;
  final Anchor? anchor;
  const GalliMarker(
      {Key? key,
      required this.latlng,
      required this.markerWidget,
      this.anchor});
  Marker toMarker() {
    return Marker(
        point: latlng,
        builder: (_) => markerWidget,
        anchorPos:
            anchorToAnchorPos(anchor) ?? AnchorPos.align(AnchorAlign.center));
  }
}

enum Anchor { top, center, bottom, right, left }

AnchorPos? anchorToAnchorPos(Anchor? anchor) {
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
