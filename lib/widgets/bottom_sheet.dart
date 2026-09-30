import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uw_navigator/models/building.dart';
import 'package:uw_navigator/providers/position_provider.dart';
import '../providers/app_state.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({super.key});

  //Builds the bottom sheet that appears when a building marker is tapped
  //Shows building name, hours, accessibility info, navigate button, and save button
  //Returns SizedBox.shrink if no building is selected
  //Parameters:
  //  - context: First Variable BuildContext
  //Returns the bottom sheet container or empty widget if no building selected
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final Building? building = appState.selectedBuilding;
    
    if (building == null) {
      return const SizedBox.shrink();
    }

    final isSaved = appState.isSaved(building);
    
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          // Building info row
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_city,
                  color: Color(0xFFFF6F00),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      building.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          building.hours,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          building.accessible
                              ? Icons.accessible
                              : Icons.accessible_forward,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          building.accessible ? 'Accessible' : 'Not accessible',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          building.elevators
                              ? Icons.elevator
                              : Icons.stairs,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          building.elevators ? 'Elevators' : 'No elevators',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: Semantics(
                label: 'Navigate to ${building.name}',
                button: true,
                  child: ElevatedButton.icon(
                    onPressed: () => _drawRoute(context, building),
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text(
                      'Navigate',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Star/Save button
              Semantics(
                label: isSaved ? 'Remove ${building.name} from saved' : 'Save ${building.name}',
                button: true,
                child: GestureDetector(
                  onTap: () => appState.toggleSaveBuilding(building),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSaved
                          ? const Color(0xFFFFF3E0)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSaved
                            ? const Color(0xFFFF6F00)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Icon(
                      isSaved ? Icons.star : Icons.star_border,
                      color: isSaved
                          ? const Color(0xFFFF6F00)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Walking time display
          Consumer<AppState>(
            builder: (context, appState, _) {
              if (appState.walkingTime.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_walk, size: 16, color: Color(0xFFFF6F00)),
                    const SizedBox(width: 6),
                    Text(
                      appState.walkingTime,
                      style: const TextStyle(
                        color: Color(0xFFFF6F00),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  //Draws the walking route from current GPS location to the selected building
  //First attempts Valhalla routing API and falls back to OSRM if Valhalla fails
  //Parameters:
  //  - context: First Variable BuildContext
  //  - building: Second Variable nullable Building destination
  //No Returns
  Future<void> _drawRoute(BuildContext context, Building? building) async {
    final userLat = context.read<PositionProvider>().latitude;
    final userLon = context.read<PositionProvider>().longitude;

    try {
      final http.Client client = http.Client();
      final body = jsonEncode({
        "locations": [
          {"lon": userLon, "lat": userLat},
          {"lon": building!.longitude, "lat": building.latitude}
        ],
        "costing": "pedestrian",
        "costing_options": {
          "pedestrian": {
            "walking_speed": 5.1,
            "walkway_factor": 0.05,
            "use_roads": 0.0,
            "use_tracks": 1.0,
            "use_living_streets": 1.0,
            "driveway_factor": 10.0,
            "max_hiking_difficulty": 6,
            "shortest": true
          }
        },
        "directions_options": {"units": "miles"},
        "costing_options_no_restrictions": true
      });

      final response = await client.post(
        Uri.parse('https://valhalla1.openstreetmap.de/route'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final parsedResponse = jsonDecode(response.body);
      final List<dynamic> legs = parsedResponse['trip']['legs'];
      final double duration =
          (parsedResponse['trip']['summary']['time'] as num).toDouble();
      final String encodedShape = legs[0]['shape'];
      final List<LatLng> points = _decodePolyline(encodedShape);

      if (context.mounted) {
        context.read<AppState>().setRouteData(points, duration);
      }
    } catch (e) {
      // Fallback to OSRM
      try {
        final http.Client client = http.Client();
        final response = await client.get(Uri.parse(
          'https://router.project-osrm.org/route/v1/foot/'
          '$userLon,$userLat;${building!.longitude},${building.latitude}'
          '?overview=full&geometries=geojson'));
        final parsedResponse = jsonDecode(response.body);
        final List<dynamic> coordinates =
            parsedResponse['routes'][0]['geometry']['coordinates'];
        final double duration =
            (parsedResponse['routes'][0]['duration'] as num).toDouble();
        final List<LatLng> points = coordinates.map((point) =>
            LatLng((point[1] as num).toDouble(),
                  (point[0] as num).toDouble())).toList();
        if (context.mounted) {
          context.read<AppState>().setRouteData(points, duration);
        }
      } catch (e2) {
        debugPrint('Both routing services failed: $e2');
      }
    }
  }

  //Decodes the encoded polyline string returned from Valhalla routing API
  //Valhalla uses precision 6 encoding so divides by 1e6 to get actual coordinates
  //Parameters:
  //  - encoded: First Variable String encoded polyline from Valhalla response
  //Returns the decoded list of LatLng coordinate objects
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lon = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lat += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

      shift = 0; result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lon += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

      points.add(LatLng(lat / 1e6, lon / 1e6));
    }
    return points;
  }
}