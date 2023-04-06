import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:galli_map/galli_map.dart';
import 'package:galli_map/src/functions/cache.dart';
import 'package:galli_map/src/functions/encrption.dart';
import 'package:galli_map/src/models/image_model.dart';
import 'package:galli_map/src/utils/latlng.dart';
import 'package:galli_map/src/utils/location.dart';
import 'package:galli_map/src/widgets/markers/user_location_marker.dart';
import 'package:galli_map/src/widgets/viewer/galli360viewer.dart'
    as galliViewer;
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
  final LatLng? initialPosition;
  final double three60MarkerSize;
  final Function(MapController controller)? onMapLoadComplete;
  final Function(AutoCompleteModel autoCompleteData)? onTapAutoComplete;
  final Function(MapEvent mapEvent)? onMapUpdate;
  final Widget Function(BuildContext, List<Marker>)? markerClusterWidget;
  final Function(
    LatLng latLng,
  )? onTap;
  final Function(String image)? on360MarkerTap;
  final galliViewer.Viewer? viewer;
  const GalliMap(
      {Key? key,
      required this.authKey,
      required this.controller,
      this.height,
      this.width,
      this.zoom = 16,
      this.maxZoom = 18,
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
      this.on360MarkerTap,
      this.initialPosition,
      this.children = const <Widget>[],
      this.onMapUpdate,
      this.viewer,
      this.three60MarkerSize = 20,
      this.markerClusterWidget})
      : super(key: key);

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
  bool three60Loading = false;

  typingWait() async {
    if (_search.text.length > 2) {
      typingWaiter =
          Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (timer.tick == 5) {
          if (!mounted) {
            typingWaiter!.cancel();
            return;
          }
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
          if (!mounted) {
            typingWaiter!.cancel();
            return;
          }
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
    if (!mounted) {
      return;
    }
    setState(() {});
    galliMethods!.streamCurrentLocation().listen((event) {
      if (isFromNepal(event.toLatLng())) {
        currentLocation = event;
        if (!mounted) {
          return;
        }
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
                  plugins: [
                    MarkerClusterPlugin(),
                  ],
                  onMapCreated: (controller) async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (widget.onMapLoadComplete != null) {
                      widget.onMapLoadComplete!(controller);
                    }
                    controller.mapEventStream.listen((event) async {
                      if (widget.onMapUpdate != null)
                        widget.onMapUpdate!(event);

                      if (!three60Loading &&
                          images.isNotEmpty &&
                          (event is MapEventMoveEnd ||
                              event is MapEventRotateEnd ||
                              event is MapEventFlingAnimationEnd)) {
                        if (!mounted) return;
                        setState(() {
                          three60Loading = true;
                        });
                        print("Getting images");
                        images = await galliMethods!
                            .get360ImagePoints(widget.controller.map);

                        if (!mounted) return;
                        setState(() {
                          three60Loading = false;
                        });
                      }
                    });
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
                  center: widget.initialPosition ?? center,
                  maxZoom: widget.maxZoom,
                  minZoom: widget.minZoom,
                  zoom: widget.zoom),
              layers: [
                TileLayerOptions(
                    tms: true,
                    tileProvider: const CachedTileProvider(),
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
                MarkerClusterLayerOptions(
                    markers: [
                      for (ImageModel image in images)
                        Marker(
                            height: widget.three60MarkerSize,
                            point: LatLng(image.lat!, image.lng!),
                            builder: (_) => GestureDetector(
                                  onTap: () {
                                    String data = encrypt(
                                        "${image.folder}/${image.image}");
                                    if (widget.on360MarkerTap != null) {
                                      widget.on360MarkerTap!(data);
                                    }
                                  },
                                  child: Container(
                                    width: widget.three60MarkerSize,
                                    height: widget.three60MarkerSize,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 2, color: Colors.orange)),
                                  ),
                                )),
                    ],
                    builder: (context, marker) {
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.orange)),
                        child: Center(
                          child: Text(marker.length.toString()),
                        ),
                      );
                    }),
                MarkerClusterLayerOptions(
                    markers: [
                      for (GalliMarker marker in widget.markers)
                        marker.toMarker(),
                    ],
                    builder: widget.markerClusterWidget ??
                        (context, marker) {
                          return Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 2, color: Colors.blue)),
                            child: Center(
                              child: Text(marker.length.toString()),
                            ),
                          );
                        }),
                MarkerLayerOptions(markers: [
                  if (widget.showCurrentLocation)
                    userLocation(
                        latLng: currentLocation!.toLatLng(),
                        marker: widget.currentLocationMarker),
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
                                if (!mounted) {
                                  return;
                                }
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
                            if (!mounted) {
                              return;
                            }
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
                              if (!mounted) {
                                return;
                              }
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
                                            if (!mounted) {
                                              return;
                                            }
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
                                        if (!mounted) {
                                          return;
                                        }
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
                            if (!three60Loading) {
                              if (images.isEmpty) {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  three60Loading = true;
                                });
                                images = await galliMethods!
                                    .get360ImagePoints(widget.controller.map);
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  three60Loading = false;
                                });
                              } else {
                                images = [];
                              }
                              if (!mounted) {
                                return;
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
                                    child: three60Loading
                                        ? CircularProgressIndicator()
                                        : Stack(children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
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
                                                padding: const EdgeInsets.only(
                                                    bottom: 12),
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
