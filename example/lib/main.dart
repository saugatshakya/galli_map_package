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
  final GalliMethods galliMethods = GalliMethods("k61f40b24-8281-11ed-b9f29f2");

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
                onMapLoadComplete: (controller) async {
                  // galliMethods.animateMapMove(LatLng(27.709857, 85.339195), 18,
                  //     this, mounted, controller);
                },
                authKey: "61f40b24-8281-11ed-b9f29f2",
                controller: controller,
                zoom: 16,
                initialPosition: LatLng(27.672905, 85.312215),
                showCurrentLocation: false,
                onTap: (tap) {},
                on360MarkerTap: (image) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Viewer(
                            image: image,
                          )));
                },
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
                markers: [
                  GalliMarker(
                      latlng: LatLng(27.684222, 85.30134),
                      anchor: Anchor.top,
                      markerWidget: const Icon(
                        Icons.location_history_sharp,
                        color: Colors.white,
                        size: 48,
                      )),
                  GalliMarker(
                      latlng: LatLng(27.684222, 85.30134),
                      anchor: Anchor.top,
                      markerWidget: const Icon(
                        Icons.location_history_sharp,
                        color: Colors.white,
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
