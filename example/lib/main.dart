import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galli_map/galli_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final GalliController controller = GalliController();
  final GalliMethods galliMethods =
      GalliMethods("89a40903-b75a-46b6-822b-86eebad4fa36");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              child: GalliMap(
                onTapAutoComplete: (AutoCompleteModel model) async {
                  FeatureModel? feature = await galliMethods.search(
                      model.name!, controller.map.center);
                  if (feature != null) {
                    await galliMethods.getRoute(
                        source: controller.map.center,
                        destination: feature.geometry!.coordinates!.first);
                  }
                },
                onMapLoadComplete: (controller) async {
                  // galliMethods.animateMapMove(LatLng(27.709857, 85.339195), 18,
                  //     this, mounted, controller);
                },
                authKey: "89a40903-b75a-46b6-822b-86eebad4fa36",
                controller: controller,
                zoom: 16,
                initialPosition: LatLng(27.672905, 85.312215),
                showCurrentLocation: true,
                viewer: Viewer(
                    accessToken: "89a40903-b75a-46b6-822b-86eebad4fa36",
                    pinIcon: Icon(
                      Icons.abc,
                      size: 48,
                    ),
                    animSpeed: 2,
                    height: 300,
                    width: 300,
                    onSaved: (x, y) {
                      print("$x,$y");
                    }),
                onTap: (tap) {
                  galliMethods.reverse(tap);
                },
                on360MarkerTap: () {},
                onMapUpdate: (event) {},
                circles: [
                  GalliCircle(
                      center: LatLng(27.684222, 85.303778),
                      radius: 54,
                      color: Colors.white,
                      borderStroke: 3,
                      borderColor: Colors.black)
                ],
                lines: [
                  GalliLine(
                      line: [
                        LatLng(27.684222, 85.303778),
                        LatLng(27.684246, 85.303780),
                        LatLng(27.684222, 85.303790),
                        LatLng(27.684230, 85.303778),
                      ],
                      borderColor: Colors.blue,
                      borderStroke: 2,
                      lineColor: Colors.white,
                      lineStroke: 2)
                ],
                polygons: [
                  GalliPolygon(
                    polygon: [
                      LatLng(27.684222, 85.303778),
                      LatLng(27.684246, 85.303780),
                      LatLng(27.684222, 85.303790),
                      LatLng(27.684290, 85.303754),
                    ],
                    borderColor: Colors.red,
                    borderStroke: 2,
                    color: Colors.green,
                  ),
                ],
                children: [
                  Positioned(
                      top: 64,
                      right: 64,
                      child: Container(
                        width: 32,
                        height: 32,
                        color: Colors.yellow,
                      ))
                ],
                markerClusterWidget: (context, list) {
                  return Container(
                    width: 20,
                    height: 20,
                    color: Colors.red,
                    child: Center(
                      child: Text(list.length.toString()),
                    ),
                  );
                },
                viewerPosition: Offset(32, 32),
                markers: [
                  GalliMarker(
                      latlng: LatLng(27.684222, 85.30134),
                      anchor: Anchor.top,
                      markerWidget: const Icon(
                        Icons.location_history,
                        color: Colors.black,
                        size: 48,
                      )),
                  GalliMarker(
                      latlng: LatLng(27.684222, 85.30134),
                      anchor: Anchor.top,
                      markerWidget: const Icon(
                        Icons.location_history,
                        color: Colors.black,
                        size: 48,
                      )),
                  GalliMarker(
                      latlng: LatLng(27.684222, 85.30134),
                      anchor: Anchor.top,
                      markerWidget: const Icon(
                        Icons.location_history,
                        color: Colors.black,
                        size: 48,
                      )),
                  GalliMarker(
                      latlng: LatLng(27.684222, 85.30134),
                      anchor: Anchor.top,
                      markerWidget: const Icon(
                        Icons.location_history,
                        color: Colors.black,
                        size: 48,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
