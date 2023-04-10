import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:galli_map/galli_map.dart';
import 'package:galli_map/src/functions/api.dart';
import 'package:galli_map/src/models/image_model.dart';
import 'package:galli_map/src/static/url.dart';
import 'package:galli_map/src/utils/location.dart';
import 'package:geolocator/geolocator.dart';

class GalliMethods {
  final String accessToken;
  GalliMethods(this.accessToken);
  Future<List<AutoCompleteModel>> autoComplete(String query) async {
    var response = await geoApi.get(galliUrl.autoComplete(query), accessToken);
    List<AutoCompleteModel> autoCompleteResults = [];
    if (response != [] && response != null) {
      var datas = jsonDecode(response);
      for (var data in datas) {
        AutoCompleteModel autoCompleteData = AutoCompleteModel.fromJson(data);
        autoCompleteResults.add(autoCompleteData);
      }
    }
    return autoCompleteResults;
  }

  Future<FeatureModel?> search(String query, LatLng location) async {
    var response = await geoApi.get(
        galliUrl.search(query, LatLng(location.latitude, location.longitude)),
        accessToken);
    if (response != [] && response != null) {
      List<FeatureModel> features = [];
      var datas = jsonDecode(response)["features"];
      for (var data in datas) {
        FeatureModel featureData = FeatureModel.fromJson(data);
        features.add(featureData);
      }
      return features.first;
    } else {
      return null;
    }
  }

  Future<HouseModel?> reverse(LatLng latLng) async {
    var response =
        await geoApi.get(galliUrl.reverseGeoCode(latLng), accessToken);
    if (response != null) {
      var data = jsonDecode(response);
      List<LatLng> coord = [];
      if (data["houseCoords"] != null) {
        data['houseCoords'][0][0].forEach((v) {
          coord.add(LatLng(v[1], v[0]));
        });
      }
      HouseModel house = HouseModel(
        featurecode: data["gallicode"],
        streetNameEn: data["generalName"],
        houseCode: data["houseNumber"],
        coordinate: coord,
        center: latLng,
      );
      return house;
    } else {
      return null;
    }
  }

  Future<RouteInfo?> getRoute({
    required LatLng source,
    required LatLng destination,
  }) async {
    var response = await geoApi.get(
        galliUrl.getRoute(source: source, destination: destination),
        accessToken);
    if (response != null) {
      var data = jsonDecode(response);
      RouteInfo route = RouteInfo.fromJson(data["data"][0]);
      return route;
    } else {
      return null;
    }
  }

  Future<List<ImageModel>> get360ImagePoints(
      MapController mapController) async {
    String? three60ImagesString = await galliApi.get(
        galliUrl.get360Points(mapController.bounds!.southWest!,
            mapController.bounds!.northEast!, mapController.zoom),
        accessToken);
    List<ImageModel> three60ImageModel = [];

    if (three60ImagesString != null) {
      List three60Images = await jsonDecode(three60ImagesString);
      for (var three60ImageString in three60Images) {
        ImageModel image = ImageModel.fromJson(three60ImageString);
        three60ImageModel.add(image);
      }
    }
    return three60ImageModel;
  }

  Future<Position> getCurrentLocation() async {
    Position currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (isFromNepal(
        LatLng(currentLocation.latitude, currentLocation.longitude))) {
    } else {
      currentLocation = const Position(
          longitude: 85.304835,
          latitude: 27.682361,
          timestamp: null,
          accuracy: 12,
          altitude: 100,
          heading: 0,
          speed: 0,
          speedAccuracy: 12);
    }
    return currentLocation;
  }

  Stream<Position> streamCurrentLocation() {
    return Geolocator.getPositionStream(
        desiredAccuracy: LocationAccuracy.best,
        distanceFilter: 20,
        intervalDuration: const Duration(milliseconds: 500));
  }

  Future animateMapMove(LatLng destLocation, double destZoom, vsync, mounted,
      mapController) async {
    if (!mounted) return;
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);
    if (!mounted) return;
    var controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: vsync);
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.decelerate);
    controller.addListener(() {
      mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    await controller.forward();
  }

  rotateMap(vsync, mounted, MapController mapController) async {
    if (!mounted) return;

    final rotateTween = Tween<double>(begin: mapController.rotation, end: 0.0);
    if (!mounted) return;
    var controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: vsync);
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.decelerate);
    controller.addListener(() {
      mapController.rotate(rotateTween.evaluate(animation));
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    await controller.forward();
  }
}
