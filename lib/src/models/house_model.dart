import 'dart:developer';
import 'package:galli_map/src/models/feature_model.dart';
import 'package:latlong2/latlong.dart';

class HouseModel {
  int? id;
  String? featurecode;
  int? number;
  String? houseCode;
  String? maxlat;
  String? minlat;
  String? maxlong;
  String? minlong;
  int? osmId;
  String? uniqueId;
  String? bin;
  String? streetCode;
  String? metAddress;
  String? ownerName;
  String? buildingRemark;
  String? ward;
  String? picture;
  String? objectId;
  String? type;
  String? streetNameEn;
  LatLng? center;
  Address? address;
  List<LatLng>? coordinate;

  HouseModel({
    this.id,
    this.featurecode,
    this.number,
    this.houseCode,
    this.maxlat,
    this.minlat,
    this.maxlong,
    this.minlong,
    this.osmId,
    this.uniqueId,
    this.bin,
    this.streetCode,
    this.metAddress,
    this.ownerName,
    this.buildingRemark,
    this.ward,
    this.picture,
    this.objectId,
    this.type,
    this.streetNameEn,
    this.center,
    this.address,
    this.coordinate,
  });

  HouseModel.fromFeature(FeatureModel feature, String name) {
    streetNameEn = name;
    center = feature.geometry!.type == FeatureType.point
        ? feature.geometry!.coordinates!.first
        : feature.geometry!.listOfCoordinates!.first[0];
  }

  HouseModel.fromFeatureString(Map<String, dynamic> json) {
    streetNameEn = json['street_name_en'];
    houseCode = json['house_code'];
    featurecode = json['featurecode'];
    center = LatLng(
        json['center']['coordinates'][1], json['center']['coordinates'][0]);
    if (json['coordinate'] != null) {
      coordinate = <LatLng>[];
      json['coordinate'].forEach((v) {
        log(v.toString());
        coordinate!.add(LatLng(v['coordinates'][1], v['coordinates'][0]));
      });
    }
  }

  HouseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    featurecode = json['featurecode'];
    number = json['number'];
    houseCode = json['house_code'];
    maxlat = json['maxlat'];
    minlat = json['minlat'];
    maxlong = json['maxlong'];
    minlong = json['minlong'];
    osmId = json['osm_id'];
    uniqueId = json['unique_id'];
    bin = json['bin'].toString();
    streetCode = json['street_code'];
    metAddress = json['met_address'];
    ownerName = json['owner_name'];
    buildingRemark = json['building_remark'];
    ward = json['ward'];
    picture = json['picture'];
    objectId = json['object_id'];
    type = json['type'];
    streetNameEn = json['street_name_en'];
    center = json['center'] != null
        ? LatLng(double.parse(json['center']['latitude']),
            double.parse(json['center']['longitude']))
        : null;
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    if (json['coordinate'] != null) {
      coordinate = <LatLng>[];
      json['coordinate'][0].forEach((v) {
        coordinate!.add(
            LatLng(double.parse(v["latitude"]), double.parse(v["longitude"])));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['featurecode'] = featurecode;
    data['number'] = number;
    data['house_code'] = houseCode;
    data['maxlat'] = maxlat;
    data['minlat'] = minlat;
    data['maxlong'] = maxlong;
    data['minlong'] = minlong;
    data['osm_id'] = osmId;
    data['unique_id'] = uniqueId;
    data['bin'] = bin;
    data['street_code'] = streetCode;
    data['met_address'] = metAddress;
    data['owner_name'] = ownerName;
    data['building_remark'] = buildingRemark;
    data['ward'] = ward;
    data['picture'] = picture;
    data['object_id'] = objectId;
    data['type'] = type;
    data['street_name_en'] = streetNameEn;
    if (center != null) {
      data['center'] = center!.toJson();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['coordinate'] = coordinate;
    return data;
  }

  LatLng calculateCenterCoordinate(List<LatLng> coordinates) {
    double xSum = 0.0;
    double ySum = 0.0;

    for (int i = 0; i < coordinates.length; i++) {
      xSum += coordinates[i].latitude;
      ySum += coordinates[i].longitude;
    }

    double xCenter = xSum / coordinates.length;
    double yCenter = ySum / coordinates.length;

    return LatLng(xCenter, yCenter);
  }
}

class Address {
  int? id;
  int? statecode;
  String? district;
  String? municipal;
  int? ward;
  StatePlace? state;

  Address(
      {this.id,
      this.statecode,
      this.district,
      this.municipal,
      this.ward,
      this.state});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    statecode = json['statecode'];
    district = json['district'];
    municipal = json['municipal'];
    ward = json['ward'];
    state = json['state'] != null ? StatePlace.fromJson(json['state']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['statecode'] = statecode;
    data['district'] = district;
    data['municipal'] = municipal;
    data['ward'] = ward;
    if (state != null) {
      data['state'] = state!.toJson();
    }
    return data;
  }
}

class StatePlace {
  String? name;
  String? alternate;

  StatePlace({this.name, this.alternate});

  StatePlace.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    alternate = json['alternate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['alternate'] = alternate;
    return data;
  }
}
