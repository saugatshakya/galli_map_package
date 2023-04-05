import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:galli_map/galli_map.dart';
import 'package:galli_map/src/models/image_model.dart';
import 'package:galli_map/src/utils/latlng.dart';
import 'package:galli_map/src/utils/location.dart';
import 'package:galli_map/src/widgets/markers/user_location_marker.dart';
import 'package:geolocator/geolocator.dart';

class GalliMap extends StatefulWidget {
  final String authKey;
  final double? height;
  final double? width;
  final double zoom;
  final double maxZoom;
  final double minZoom;
  final bool showCurrentLocation;
  final Widget? currentLocationMarker;
  final List<GalliMarker> markers;
  final List<GalliLine> lines;
  final List<GalliCircle> circles;
  final List<GalliPolygon> polygons;
  final bool showSearch;
  final bool show360Button;
  final Widget? three60Widget;
  final bool showLocationButton;
  final Widget? currentLocationWidget;
  final String? searchHint;
  final GalliController controller;
  final List<Widget> children;
  final Function(MapController controller)? onMapLoadComplete;
  final Function(AutoCompleteModel autoCompleteData)? onTapAutoComplete;
  final Function(
    LatLng latLng,
  )? onTap;
  const GalliMap({
    Key? key,
    required this.authKey,
    required this.controller,
    this.height,
    this.width,
    this.zoom = 16,
    this.maxZoom = 22,
    this.minZoom = 10,
    this.showCurrentLocation = true,
    this.currentLocationMarker,
    this.markers = const <GalliMarker>[],
    this.onTap,
    this.showSearch = true,
    this.show360Button = true,
    this.three60Widget,
    this.showLocationButton = true,
    this.currentLocationWidget,
    this.searchHint = "Find Places",
    this.lines = const <GalliLine>[],
    this.circles = const <GalliCircle>[],
    this.polygons = const <GalliPolygon>[],
    this.onTapAutoComplete,
    this.onMapLoadComplete,
    this.children = const <Widget>[],
  }) : super(key: key);

  @override
  State<GalliMap> createState() => _GalliMapState();
}

class _GalliMapState extends State<GalliMap> with TickerProviderStateMixin {
  Position? currentLocation;
  final TextEditingController _search = TextEditingController();
  bool showSearch = false;
  List<AutoCompleteModel> autocompleteResults = [];
  List<ImageModel> images = [];
  Timer? typingWaiter;
  bool loading = false;
  LatLng center = LatLng(27.697297, 85.329238);

  typingWait() async {
    if (_search.text.length > 2) {
      typingWaiter =
          Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (timer.tick == 5) {
          setState(() {
            loading = true;
          });
          typingWaiter!.cancel();
          List<AutoCompleteModel> tempData =
              await galliMethods!.autoComplete(_search.text);
          List<AutoCompleteModel> data = tempData.toSet().toList();
          if (data.isNotEmpty) {
            autocompleteResults = data;
          }
          if (!mounted) return;
          setState(() {
            loading = false;
          });
        }
      });
    }
  }

  locationaServicesInitiate() async {
    currentLocation = await galliMethods!.getCurrentLocation();
    center = currentLocation!.toLatLng();
    setState(() {});
    galliMethods!.streamCurrentLocation().listen((event) {
      if (isFromNepal(event.toLatLng())) {
        currentLocation = event;
        setState(() {});
      }
    });
  }

  GalliMethods? galliMethods;

  @override
  void initState() {
    galliMethods = GalliMethods(widget.authKey);
    locationaServicesInitiate();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? MediaQuery.of(context).size.width,
      height: widget.height ?? MediaQuery.of(context).size.height,
      child: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xff454545),
              ),
            )
          : FlutterMap(
              mapController: widget.controller.map,
              options: MapOptions(
                  onMapCreated: (controller) {
                    if (widget.onMapLoadComplete != null) {
                      widget.onMapLoadComplete!(controller);
                    }
                  },
                  onPositionChanged: (pos, __) {
                    center = pos.center!;
                  },
                  onTap: (__) {
                    if (widget.onTap != null) {
                      widget.onTap!(__);
                    }
                  },
                  interactiveFlags: InteractiveFlag.all,
                  center: center,
                  maxZoom: widget.maxZoom,
                  minZoom: widget.minZoom,
                  zoom: widget.zoom),
              layers: [
                TileLayerOptions(
                    tms: true,
                    urlTemplate:
                        "https://map.gallimap.com/geoserver/gwc/service/tms/1.0.0/GalliMaps%3AGalliMaps@EPSG%3A3857@png/{z}/{x}/{y}.png?authkey=${widget.authKey}"),
                PolylineLayerOptions(polylines: [
                  for (GalliLine line in widget.lines) line.toPolyline(),
                ]),
                PolygonLayerOptions(polygons: [
                  for (GalliPolygon polygon in widget.polygons)
                    polygon.toPolygon(),
                ]),
                CircleLayerOptions(
                  circles: [
                    for (GalliCircle circle in widget.circles)
                      circle.toCircleMarker(),
                  ],
                ),
                MarkerLayerOptions(markers: [
                  if (widget.showCurrentLocation)
                    userLocation(
                        latLng: currentLocation!.toLatLng(),
                        marker: widget.currentLocationMarker),
                  for (GalliMarker marker in widget.markers) marker.toMarker(),
                  for (ImageModel image in images)
                    Marker(
                        height: 16,
                        point: LatLng(image.lat!, image.lng!),
                        builder: (_) => Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 2, color: Colors.orange)),
                            ))
                ]),
              ],
              nonRotatedChildren: [
                if (widget.children.isNotEmpty)
                  for (Widget child in widget.children) child,
                if (showSearch)
                  Container(
                    width: widget.width ?? MediaQuery.of(context).size.width,
                    height: widget.height ?? MediaQuery.of(context).size.height,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 64,
                          ),
                          for (AutoCompleteModel autoCompleteData
                              in autocompleteResults)
                            GestureDetector(
                              onTap: () async {
                                if (widget.onTapAutoComplete != null) {
                                  await widget
                                      .onTapAutoComplete!(autoCompleteData);
                                }
                                showSearch = false;
                                autocompleteResults = [];
                                _search.text = autoCompleteData.name!;
                                setState(() {});
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.orange))),
                                child: ListTile(
                                  horizontalTitleGap: 0,
                                  minLeadingWidth: 48,
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: Colors.orange,
                                  ),
                                  title: Text(
                                    autoCompleteData.name ?? "null",
                                    style: const TextStyle(
                                        fontSize: 14, color: Color(0xff454545)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (widget.showSearch)
                  Positioned(
                    top: 16,
                    left: MediaQuery.of(context).size.width * 0.05,
                    child: Material(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 4,
                      child: SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                          controller: _search,
                          onTap: () {
                            setState(() {
                              showSearch = true;
                            });
                          },
                          onChanged: (val) async {
                            if (val != "") {
                              if (typingWaiter != null) {
                                typingWaiter!.cancel();
                              }
                              typingWait();
                            } else {
                              setState(() {
                                autocompleteResults = [];
                              });
                            }
                          },
                          decoration: InputDecoration(
                              hintText: widget.searchHint,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.orange,
                                ),
                              ),
                              suffixIcon: _search.text == ""
                                  ? !showSearch
                                      ? const SizedBox()
                                      : InkWell(
                                          onTap: () {
                                            showSearch = false;
                                            autocompleteResults = [];
                                            setState(() {});
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            child: const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.orange,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        )
                                  : InkWell(
                                      onTap: () {
                                        _search.text = "";
                                        setState(() {});
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.only(top: 8)),
                          cursorColor: const Color(0xff454545),
                          cursorHeight: 12,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff454545),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      if (widget.show360Button)
                        GestureDetector(
                          onTap: () async {
                            if (!loading) {
                              if (images.isEmpty) {
                                setState(() {
                                  loading = true;
                                });
                                images = await galliMethods!
                                    .get360ImagePoints(widget.controller.map);
                                setState(() {
                                  loading = false;
                                });
                              } else {
                                images = [];
                              }
                              setState(() {});
                            }
                          },
                          child: widget.three60Widget ??
                              Card(
                                  elevation: 4,
                                  color: images.isEmpty
                                      ? Colors.white
                                      : Colors.orange,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Stack(children: [
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.threesixty,
                                                size: 25,
                                                color: images.isEmpty
                                                    ? Colors.orange
                                                    : Colors.white,
                                              ))),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "360",
                                                style: TextStyle(
                                                    color: images.isEmpty
                                                        ? Colors.orange
                                                        : Colors.white,
                                                    fontSize: 8,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ))),
                                    ]),
                                  )),
                        ),
                      if (widget.showLocationButton)
                        GestureDetector(
                          onTap: () {
                            // galliMethods!.animateMapMove(
                            //     LatLng(27.728351, 85.301382),
                            //     18,
                            //     this,
                            //     mounted,
                            //     widget.controller.map);
                            if (widget.controller.map.rotation != 0.0) {
                              galliMethods!.rotateMap(
                                  this, mounted, widget.controller.map);
                            } else if (widget.controller.map.center !=
                                currentLocation!.toLatLng()) {
                              galliMethods!.animateMapMove(
                                  currentLocation!.toLatLng(),
                                  widget.controller.map.zoom,
                                  this,
                                  mounted,
                                  widget.controller.map);
                            } else if (widget.controller.map.zoom != 16) {
                              galliMethods!.animateMapMove(
                                  currentLocation!.toLatLng(),
                                  16,
                                  this,
                                  mounted,
                                  widget.controller.map);
                            }
                          },
                          child: widget.currentLocationWidget ??
                              Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  child: const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: Icon(
                                        Icons.location_searching_outlined,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  )),
                        ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
