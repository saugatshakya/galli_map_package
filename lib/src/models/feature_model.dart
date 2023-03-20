import 'package:latlong2/latlong.dart';

class FeatureModel {
  String? type;
  Properties? properties;
  Geometry? geometry;

  FeatureModel({this.type, this.properties, this.geometry});

  FeatureModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    properties = json['properties'] != null
        ? Properties.fromJson(json['properties'])
        : null;
    geometry =
        json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (properties != null) {
      data['properties'] = properties!.toJson();
    }
    if (geometry != null) {
      data['geometry'] = geometry!.toJson();
    }
    return data;
  }
}

class Properties {
  double? distance;
  String? category;

  Properties({this.distance, this.category});

  Properties.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['category'] = category;
    return data;
  }
}

class Geometry {
  FeatureType? type;
  List<LatLng>? coordinates;
  List<List<LatLng>>? listOfCoordinates;

  Geometry({this.type, this.coordinates, this.listOfCoordinates});

  Geometry.fromJson(Map<String, dynamic> json) {
    type = stringToFeatureType(json['type']);
    coordinates = type == FeatureType.point
        ? jibbrishToCoordinates(json['coordinates'], type!)[0]
        : null;
    listOfCoordinates = type != FeatureType.point
        ? jibbrishToCoordinates(json['coordinates'], type!)[1]
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (coordinates != null) {
      data['coordinates'] = coordinates!.map((v) => v.toJson()).toList();
    }
    data['list_of)coordinates'] = listOfCoordinates!;
    return data;
  }
}

FeatureType stringToFeatureType(String string) {
  try {
    return FeatureType.values.byName(string.toLowerCase());
  } catch (e) {
    return FeatureType.other;
  }
}

jibbrishToCoordinates(List jibbrish, FeatureType type) {
  List<LatLng> coordinates = [];
  List<List<LatLng>> listOfCoordinates = [];
  switch (type) {
    case FeatureType.point:
      LatLng latlng = LatLng(jibbrish[1], jibbrish[0]);
      coordinates.add(latlng);
      break;
    case FeatureType.multilinestring:
      List<LatLng> data = [];
      for (var mainData in jibbrish) {
        for (var childData in mainData) {
          LatLng latLng = LatLng(childData[1], childData[0]);
          data.add(latLng);
        }
      }
      listOfCoordinates.add(data);
      break;
    case FeatureType.multipolygon:
      List<LatLng> data = [];
      for (var mainData in jibbrish) {
        for (var childData in mainData) {
          for (var innerChildData in childData) {
            LatLng latLng = LatLng(innerChildData[1], innerChildData[0]);
            data.add(latLng);
          }
        }
      }
      listOfCoordinates.add(data);
      break;
    case FeatureType.other:
      break;
  }
  return [coordinates, listOfCoordinates];
}

enum FeatureType { point, multilinestring, multipolygon, other }
