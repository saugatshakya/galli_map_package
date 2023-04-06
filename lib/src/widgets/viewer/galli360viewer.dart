import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:galli_map/src/functions/encrption.dart';
import 'package:panorama/panorama.dart';

/// A widget that displays a panoramic image at the specified coordinates,
/// with optional markers and interactive features.
class Viewer extends StatefulWidget {
  const Viewer({
    Key? key,
    this.height,
    this.width,
    this.loadingWidget,
    this.closeWidget,
    this.pinX,
    this.pinY,
    this.animation,
    this.maxZoom,
    this.minZoom,
    this.animSpeed,
    this.sensitivity,
    this.pinIcon,
    this.onSaved,
    this.showClose,
    required this.image,
  }) : super(key: key);

  /// The coordinates of the location to display in the panoramic image.
  final String image;

  /// The X position of the marker, as a fraction of the width of the image.
  final double? pinX;

  /// The Y position of the marker, as a fraction of the height of the image.
  final double? pinY;

  /// The height of the panoramic image.
  final double? height;

  /// The width of the panoramic image.
  final double? width;

  /// The widget to display while the panoramic image is loading.
  final Widget? loadingWidget;

  /// The widget to display as a close button.
  final Widget? closeWidget;

  /// Whether to show the close button.
  final bool? showClose;

  /// Whether to animate the panoramic image when it is loaded.
  final bool? animation;

  /// The maximum zoom level allowed for the panoramic image.
  final double? maxZoom;

  /// The minimum zoom level allowed for the panoramic image.
  final double? minZoom;

  /// The speed of the animation when the panoramic image is loaded.
  final double? animSpeed;

  /// The sensitivity of the pan and zoom controls.
  final double? sensitivity;

  /// The icon to use for the marker.
  final IconData? pinIcon;

  /// A callback function that is called when the marker is placed.
  ///
  /// The `x` and `y` parameters represent the marker's position as fractions of the width and height of the image, respectively.
  final Function(double x, double y)? onSaved;

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  double speed = 2;
  bool imageLoaded = false;
  String? imageLink;
  bool error = false;
  double? markerX;
  double? markerY;

  @override
  void initState() {
    if (widget.animation != null && !widget.animation!) {
      speed = 0.0;
    } else if (widget.animSpeed != null) {
      speed = widget.animSpeed ?? 2;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (markerX == null && markerY == null) {
          return true;
        } else {
          setState(() {
            markerX = null;
            markerY = null;
          });
          return false;
        }
      },
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
              width: widget.width ?? MediaQuery.of(context).size.width * 0.9,
              height: widget.height ?? MediaQuery.of(context).size.height * 0.8,
              child: Stack(children: [
                Listener(
                  onPointerDown: (_) {
                    setState(() {
                      speed = 0;
                    });
                  },
                  child: Panorama(
                      longitude:
                          widget.pinY == null ? 0 : (widget.pinY! / 10000) * pi,
                      latitude:
                          widget.pinX == null ? 0 : (widget.pinX! / 10000) * pi,
                      maxZoom: widget.maxZoom ?? 5.0,
                      minZoom: widget.minZoom ?? 1.0,
                      onTap: (lng, lat, tilt) {
                        setState(() {
                          markerX = lat;
                          markerY = lng;
                        });
                      },
                      hotspots: [
                        Hotspot(
                          latitude: -90.0,
                          longitude: 90.0,
                          width: 200.0,
                          height: 200.0,
                          // widget: Image.asset('images_v2/app_icon_v2.png'),
                          widget: SvgPicture.network(
                              "https://gallimaps.com/galliIcon.svg"),
                        ),
                        widget.pinX != null && widget.pinY != null
                            ? Hotspot(
                                latitude: widget.pinX!,
                                longitude: widget.pinY!,
                                width: 150.0,
                                height: 128.0,
                                widget: Column(
                                  children: [
                                    Icon(
                                      widget.pinIcon ?? Icons.location_on,
                                      size: 64,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      height: 64,
                                    )
                                  ],
                                ),
                              )
                            : Hotspot(),
                        widget.onSaved == null &&
                                (markerX != null && markerY != null)
                            ? Hotspot(
                                latitude: markerX!,
                                longitude: markerY!,
                                width: 150.0,
                                height: 128.0,
                                widget: Column(
                                  children: [
                                    Icon(
                                      widget.pinIcon ?? Icons.location_on,
                                      size: 64,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      height: 64,
                                    )
                                  ],
                                ),
                              )
                            : Hotspot()
                      ],
                      animSpeed: speed,
                      sensitivity: widget.sensitivity ?? 2,
                      child: Image.network(
                          "https://image.gallimap.com/api/v1/streetview/${decrypt(widget.image)}")),
                ),
                widget.showClose == null || widget.showClose!
                    ? Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: widget.closeWidget ??
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: const Center(
                                      child: Icon(Icons.close_rounded)),
                                )))
                    : const SizedBox(),
                widget.onSaved == null || markerX == null || markerY == null
                    ? const SizedBox()
                    : Positioned(
                        bottom: 16,
                        left: (((widget.width ??
                                    MediaQuery.of(context).size.width * 0.9) -
                                MediaQuery.of(context).size.width * 0.2) /
                            2),
                        child: GestureDetector(
                          onTap: () {
                            widget.onSaved!(markerX!, markerY!);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: 36,
                              child: const Center(
                                child: Text("Save"),
                              ),
                            ),
                          ),
                        ))
              ])),
        ),
      ),
    );
  }
}

/// Represents a geographic coordinate.
class LatLng {
  /// The latitude of the coordinate.
  final double latitude;

  /// The longitude of the coordinate.
  final double longitude;
  LatLng({required this.latitude, required this.longitude});
}
