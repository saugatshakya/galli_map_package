# Galli Maps for Flutter
[![pub package](https://img.shields.io/pub/v/gallimaps.svg)](https://pub.dartlang.org/packages/gallimaps)


Galli Maps is a Flutter package that provides a customizable map widget for displaying maps with custom markers, lines, circles, and polygons. The widget supports zooming in and out, tapping on the map, and showing the user's current location.



## Installation

To use this package, add galli_maps as a dependency in your pubspec.yaml file:
```yaml
dependencies:
    galli_maps: ${last_version}
```

Then run flutter pub get to install the package.

## Usage

Import and add the Galli Maps widget to your project
```dart
import 'package:galli_maps/galli_maps.dart';
... ...

final Galli360 controller = Galli360(token);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GalliMaps(

           authKey: "xyz",
           controller: controller,
           zoom: 16,
           onTap: (tap) {},
           circles: [
             GalliCircle(
                 center: LatLng(27.12441, 67.12412),
                 radius: 32,
                 color: Colors.white,
                 borderStroke: 3,
                 borderColor: Colors.black)
           ],
           lines: [
             GalliLine(
                 line: [
                   LatLng(27.12441, 67.12412),
                   LatLng(27.12441, 67.12412),
                   LatLng(27.12441, 67.12412),
                   LatLng(27.12441, 67.12412)
                 ],
                 borderColor: Colors.blue,
                 borderStroke: 1,
                 lineColor: Colors.white,
                 lineStroke: 2)
           ],
           polygons: [
             GalliPolygon(polygon: [
               LatLng(27.12441, 67.12412),
               LatLng(27.12441, 67.12412),
               LatLng(27.12441, 67.12412),
               LatLng(27.12441, 67.12412)
             ], borderColor: Colors.red, borderStroke: 2, color: Colors.green),
           ],
           markers: [
             GalliMarker(
                 latlng: LatLng(27.12441, 67.12412),
                 markerWidget: const Icon(Icons.location_city))
           ],
         ),

    );
  }
 ```

## Preview
![Preview](https://github.com/Gallimaps/demo.gif)