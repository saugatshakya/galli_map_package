import 'package:latlong2/latlong.dart';

class GalliUrl {
  final String baseUrl = "https://gallimaps.com";
  final String geoUrl = "https://route.gallimap.com";

  String get360Points(LatLng minlatlng, LatLng maxLatlng, zoomLevel) =>
      "/streetmarker/${minlatlng.latitude},${minlatlng.longitude}/${maxLatlng.latitude},${maxLatlng.longitude}/$zoomLevel";
  String reverseGeoCode(LatLng latLng) =>
      "/reverseGeoApi/reverse/generalReverse/${latLng.longitude}/${latLng.latitude}";
  String autoComplete(String query) =>
      "/searchApi/geojson_getAll/search/$query";
  String search(String place, LatLng latlng) =>
      "/searchApi/geojson_currentlocation/${latlng.latitude}/${latlng.longitude}/$place";
  String getRoute({
    required LatLng source,
    required LatLng destination,
  }) =>
      "/routingAPI/driving?srcLat=${source.latitude}&srcLng=${source.longitude}&dstLat=${destination.latitude}&dstLng=${destination.longitude}";
}

final GalliUrl galliUrl = GalliUrl();
