import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uw_navigator/providers/position_provider.dart';
import 'package:uw_navigator/providers/schedule_provider.dart';
import 'package:uw_navigator/models/schedule_entry.dart';
import '../providers/app_state.dart';
import '../models/building.dart';
import '../widgets/bottom_sheet.dart';
import '../widgets/route_painter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> 
  with AutomaticKeepAliveClientMixin {

  final MapController _mapController = MapController();
  LatLng? _customPinLocation;
  bool _centeredOnUser = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    // Repaint canvas whenever map moves (fixes route panning lag)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.mapEventStream.listen((event) {
        if (mounted) setState(() {});
      });
    });
  }

  //Loads buildings from the buildings.json asset file and stores them in AppState
  //Called once on initState so buildings are available when the map first renders
  //No Parameters
  //No Returns
  Future<void> _loadBuildings() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/buildings.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> buildingsJson = jsonData['packages'] as List;
      
      final buildings = buildingsJson.map((json) => Building.fromJson(json)).toList();
      if (mounted) {
        Provider.of<AppState>(context, listen: false).loadBuildings(buildings);
      }
    } catch (e) {
      debugPrint('Error loading buildings: $e');
    }
  }

  //Builds the map screen with GPS location tracking, building markers,
  //canvas route overlay, alert banner, map controls, and bottom sheet
  //Parameters:
  //  - context: First Variable BuildContext
  //Returns the map screen scaffold with all layers stacked
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          Consumer2<AppState, PositionProvider>(
            builder: (context, appState, positionProvider, child) {
              // Show loading screen until GPS ready
              if (!positionProvider.hasLocation) {
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Loading...',
                          textStyle: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                );
              }

              // Center on user first time GPS loads
              if (!_centeredOnUser) {
                _centeredOnUser = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _mapController.move(
                      LatLng(positionProvider.latitude,
                          positionProvider.longitude),
                      16.0,
                    );
                  }
                });
              }

              // Convert OSRM route to screen points for canvas
              // Wrapped in try-catch because MapController may not be
              // attached yet when returning to this tab
              List<Offset> routePoints = [];
              if (appState.coordinates.isNotEmpty) {
                try {
                  routePoints = appState.coordinates.map((latLng) {
                    final point = _mapController.camera.latLngToScreenPoint(latLng);
                    return Offset(point.x, point.y);
                  }).toList();
                } catch (_) {
                  // route will appear on next frame
                  routePoints = [];
                }
              }

              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(positionProvider.latitude,
                          positionProvider.longitude),
                      initialZoom: 16.0,
                      minZoom: 14.0,
                      maxZoom: 18.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      onLongPress: (tapPosition, point) {
                        setState(() => _customPinLocation = point);
                        appState.selectBuilding(null); // clears route
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Custom pin dropped'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'CLEAR',
                              onPressed: () =>
                                  setState(() => _customPinLocation = null),
                            ),
                          ),
                        );
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.uw.navigator',
                      ),
                      CurrentLocationLayer(
                        alignPositionOnUpdate: AlignOnUpdate.never,
                        alignDirectionOnUpdate: AlignOnUpdate.never,
                        style: const LocationMarkerStyle(
                          marker: DefaultLocationMarker(
                            child: Icon(Icons.navigation, color: Colors.white),
                          ),
                          markerSize: Size(40, 40),
                          markerDirection: MarkerDirection.heading,
                        ),
                      ),
                      MarkerLayer(
                        markers: appState.buildings.map((building) {
                          return Marker(
                            point: LatLng(building.latitude, building.longitude),
                            width: 40,
                            height: 40,
                            child: Semantics(
                            label: '${building.name}. ${building.hours}. Tap to view details.',
                            button: true,
                              child: GestureDetector(
                                onTap: () => appState.selectBuilding(building),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFFF6F00),
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_customPinLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _customPinLocation!,
                              width: 50,
                              height: 50,
                              child: const Icon(Icons.push_pin,
                                  color: Colors.red, size: 50),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Canvas route overlay (drawn over map, updates with pan)
                  if (routePoints.length >= 2)
                    Positioned.fill(
                      child: ExcludeSemantics(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: RoutePainter(routePoints: routePoints),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // Alert banner (next class) - only shows when class is within 60 min
          Positioned(
            top: 100,
            left: 16,
            right: 92,
            child: _buildAlertBanner(context),
          ),
          
          // Map controls (zoom buttons)
          Positioned(
            top: 100,
            right: 16,
            child: _buildMapControls(),
          ),

          // Bottom sheet
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomSheetWidget(),
          ),
        ],
      ),
    );
  }

  //Builds the alert banner shown when a class starts within the next 60 minutes
  //Returns empty SizedBox if no classes are scheduled or none are coming up soon
  //Parameters:
  //  - context: First Variable BuildContext
  //Returns the alert banner container or SizedBox.shrink if no upcoming class
  Widget _buildAlertBanner(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final classes = scheduleProvider.schedule.entries;

    if (classes.isEmpty) return const SizedBox.shrink();

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    ScheduleEntry? nextClass;
    int? minutesUntil;

    for (final entry in classes) {
      final classMinutes =
          entry.startTime.hour * 60 + entry.startTime.minute;
      final diff = classMinutes - nowMinutes;
      if (diff >= 0 && diff <= 60) {
        if (minutesUntil == null || diff < minutesUntil) {
          minutesUntil = diff;
          nextClass = entry;
        }
      }
    }

    if (nextClass == null) return const SizedBox.shrink();

    final label = minutesUntil == 0
        ? 'CLASS STARTING NOW'
        : 'NEXT CLASS IN $minutesUntil MIN';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
            left: BorderSide(color: Color(0xFFFF6F00), width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.access_time,
                color: Color(0xFFFF6F00), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6F00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${nextClass.classCode} • ${nextClass.roomLocation}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Builds the column of zoom in, zoom out, and center location control buttons
  //No Parameters
  //Returns the column of circular icon buttons on the right side of the map
  Widget _buildMapControls() {
    return Column(
      children: [
        _buildControlButton(Icons.add, () {
          _mapController.move(
              _mapController.camera.center, _mapController.camera.zoom + 1);
        }),
        const SizedBox(height: 12),
        _buildControlButton(Icons.remove, () {
          _mapController.move(
              _mapController.camera.center, _mapController.camera.zoom - 1);
        }),
        const SizedBox(height: 12),
        _buildControlButton(Icons.my_location, () {
          final pos = Provider.of<PositionProvider>(context, listen: false);
          _mapController.move(LatLng(pos.latitude, pos.longitude), 16.0);
        }),
      ],
    );
  }

  //Builds a single circular map control button with a semantic label for accessibility
  //Determines the label text based on which icon is passed in
  //Parameters:
  //  - icon: First Variable IconData for the button icon
  //  - onPressed: Second Variable VoidCallback triggered when button is tapped
  //Returns the styled circular button wrapped in Semantics
  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    // Determine semantic label based on icon
    String label = 'Map control';
    if (icon == Icons.add) label = 'Zoom in';
    if (icon == Icons.remove) label = 'Zoom out';
    if (icon == Icons.my_location) label = 'Center map on my location';

    return Semantics(
      label: label,
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.grey[800]),
          onPressed: onPressed,
        ),
      ),
    );
  }
}