import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uw_navigator/models/building.dart';
import 'package:uw_navigator/models/schedule_entry.dart';
import 'package:uw_navigator/providers/app_state.dart';
import 'package:uw_navigator/providers/position_provider.dart';
import 'package:uw_navigator/providers/schedule_provider.dart';
import 'package:uw_navigator/screens/add_schedule_screen.dart';
import 'package:uw_navigator/screens/edit_schedule_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  //Builds the schedule screen that includes undo and redo buttons, add entry button, route schedule button,
  //and entry containers of the added classes
  //Parameters:
  //  - context: First Variable BuildContext
  //Returns the schedule screen described above
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
            'Schedule',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32
            ),
          ),
        actions: [
          // Undo button
          Consumer<ScheduleProvider>(
            builder: (context, provider, _) => Semantics(
              label: provider.canUndo ? 'Undo last action' : 'Nothing to undo',
              button: true,
              child: IconButton(
                icon: Icon(
                  Icons.undo,
                  color: provider.canUndo ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(97, 0, 0, 0),
                ),
                onPressed: provider.canUndo ? () => provider.undo() : null,
                tooltip: 'Undo',
              ),
            ),
          ),
          // Redo button
          Consumer<ScheduleProvider>(
            builder: (context, provider, _) => Semantics(
              label: provider.canRedo ? 'Redo last action' : 'Nothing to redo',
              button: true,
              child: IconButton(
                icon: Icon(
                  Icons.redo,
                  color: provider.canRedo ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(97, 0, 0, 0),
                ),
                onPressed: provider.canRedo ? () => provider.redo() : null,
                tooltip: 'Redo',
              ),
            ),
          ),
          //Add schedule entry (class) to the list button
          Semantics(
            label: 'Add new class to schedule',
            button: true,
            child: IconButton(
              onPressed: () async {
                final ScheduleEntry? entry = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const AddScheduleScreen()));
                if(entry != null && context.mounted){
                  Provider.of<ScheduleProvider>(context, listen: false).
                  addEntry(classCode: entry.classCode,
                          classDescription: entry.classDescription,
                          startTime: entry.startTime,
                          endTime: entry.endTime,
                          roomLocation: entry.roomLocation);
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              style: const ButtonStyle(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(10))
                  )
                ),
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.orange),
              ),
            ),
          ),
          //Sized box to hav spacing from edge of screen
          const SizedBox(width: 20),
        ],
      ),
    //Column that contains all of the class containers (schedule entry containers)
    body: Column(
        children: <Widget>[
          Expanded(
            child: Consumer<ScheduleProvider>(
              builder: (context, scheduleProvider, child){
                //ListView.builder used so it can scroll when enough entries are added
                  return ListView.builder(
                    itemCount: scheduleProvider.schedule.entries.length,
                    itemBuilder: (BuildContext context, int index){
                      final entry = scheduleProvider.schedule.entries[index];
                      return _createListElementForEntry(context, entry, scheduleProvider);
                    },
                  );
                //Loading screen if data is loading
              }
            )
          )
        ],
      ),
      //Button that draws the routes between the buildings within the schedule
      floatingActionButton: Semantics(
        label: 'Create route through all class buildings',
        button: true,
        child: ElevatedButton(
          onPressed: () => _drawRouteAllBuildings(context),
          child: const Text(
            'Route All Classes',
            style: TextStyle(fontSize: 18),
          )
        ),
      ),
    );
  }

  //Pushes the edit entry view screen onto the navigator so the user
  //can edit any part of their class that they had entered
  //Parameters:
  //  - context: First Variable BuildContext
  //  - entry: Named variable Nullable ScheduleEntry
  //Does not return anything

  Future<void> _navigateToEntry(BuildContext context,
      {ScheduleEntry? entry}) async {
    final newEntry = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditScheduleScreen(entry: entry)));
    if (!context.mounted){
      return; 
    }
    //if entry is not null and newEntry is not null update the entry
    if(entry != null && newEntry != null){
      Provider.of<ScheduleProvider>(context, listen: false).
        updateEntry(
          entry,
          newStartTime: newEntry.startTime,
          newEndTime: newEntry.endTime,
          newClassCode: newEntry.classCode,
          newClassDescription: newEntry.classDescription,
          newRoomLocation: newEntry.roomLocation
        );
    }
    //if for some reason entry is null but newEntry is not we add a new entry to the journal
    else if(entry == null && newEntry != null){
      Provider.of<ScheduleProvider>(context, listen: false).
        addEntry(
          classCode: newEntry.classCode,
          classDescription: newEntry.classDescription,
          startTime: newEntry.startTime,
          endTime: newEntry.endTime,
          roomLocation: newEntry.roomLocation
        );
    }
  }

  //Creates the list of classes with text button to edit class (class code text),
  //class description, room location, start and end time, navigate button, and delete button
  //Parameters:
  //  - context: First Variable BuildContext
  //  - entry: Second Variable ScheduleEntry
  //  - schedule: Third Variable ScheduleProvider
  //Returns the class containers with their respective things mentioned above

  Widget _createListElementForEntry(
    BuildContext context, 
    ScheduleEntry entry, 
    ScheduleProvider schedule){
    return Column(
      children: [
        //Semantics for accessability
        Semantics(
          label: 'Edit ${entry.classCode}',
          button: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: const BorderRadiusGeometry.all(
                        Radius.circular(10))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Edit button that has the text of the class code
                TextButton(
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.padded
                  ),
                  onPressed: () => _navigateToEntry(context, entry: entry), 
                  child: Text(
                    entry.classCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //Class description written under class code
                Text(
                  entry.classDescription,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  maxLines: 1,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Write out the start time to the end time
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.startTime.format(context)} - ${entry.endTime.format(context)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    //Write out the room location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          entry.roomLocation,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    //Create the navigation button at the bottom left of the container
                    Expanded(
                      child: Semantics(
                        label: 'Navigate to ${entry.roomLocation}',
                        button: true,
                        child: TextButton(
                          onPressed: () {
                            //grab the first 3-4 building code of the room location
                            String code = entry.roomLocation.split(' ')[0];
                            final appState = Provider.of<AppState>(context, listen: false);
                            Building? building = appState.findBuildingFromCode(code);
                            if(building != null){
                              //If the building code is valid navigate to the building specified
                              appState.selectBuilding(building);
                              _drawRoute(context, building);
                              appState.changeTab(0); // Switch to map tab
                            }
                          },
                          style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.orange),
                            minimumSize: WidgetStatePropertyAll(Size(0, 50)),
                          ),
                          child: const Text(
                            'Navigate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    //Delete button that removes the container from the list
                    Semantics(
                      label: 'Delete ${entry.classCode}',
                      button: true,
                      child: IconButton.outlined(
                        onPressed: () => schedule.removeEntry(entry), 
                        icon: const Icon(Icons.delete),
                        style: const ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.all(
                                Radius.circular(10)
                              )
                            ),
                          ),
                        )
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//Decodes the encoded polyline string returned from the api call of valhalla or OSRM
//and returns the unencoded list of latitude, longitude objects
//Parameters:
//  - encoded: First Variable String
//Returns the unencoded list of latitude, longitude objects
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

//Draws the route to the building passed in on the map screen
//Parameters:
//  - context: First Variable BuildContext
//  - building: Second Variable nullable Building
//No Returns
Future<void> _drawRoute(BuildContext context, Building? building) async {
  //assign the current latitude of the GPS
  final userLat = context.read<PositionProvider>().latitude;
  //assign the current longitude of the GPS
  final userLon = context.read<PositionProvider>().longitude;

  //try to use the Valhalla routing api first (works better with UW foot paths)
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
    // Fallback to OSRM if Valhalla has any errors
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
      //If both do not work print out the depub message below with error
      debugPrint('Both routing services failed: $e');
    }
  }
}

//Draws optimal route between all buildings within the current schedule
//Parameters:
//  - context: First Variable BuildContext
//No returns
Future<void> _drawRouteAllBuildings(BuildContext context) async {
  // Extract providers before any async gaps
  final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
  final appState = Provider.of<AppState>(context, listen: false);
  
  List<Map<String, double>> locations = <Map<String, double>>[];
  //Loop through extracting all the schedule buildiing's longitudes and latitudes and putting them in location
  for(ScheduleEntry entry in Provider.of<ScheduleProvider>(context, listen: false).schedule.entries){
    String code = entry.roomLocation.split(' ')[0];
    Building? building = Provider.of<AppState>
        (context, listen: false).findBuildingFromCode(code);
    if(building != null){
      locations.add({"lon": building.longitude, "lat": building.latitude});
    }
  }
  try {
      final http.Client client = http.Client();
      final body = jsonEncode({
        "locations": locations,
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
      final List<LatLng> points = [];
      for(dynamic leg in legs){
        points.addAll(_decodePolyline(leg['shape'].toString()));
      }

      if (context.mounted) {
        context.read<AppState>().setRouteData(points, duration);
        context.read<AppState>().changeTab(0);
      }
    } catch (e) {
      // Fallback to OSRM if Valhalla fails for any reason
      try {
        final http.Client fallbackClient = http.Client();
        String uri = 'https://router.project-osrm.org/route/v1/foot/';
        //Loop through the entries again because the api call for OSRM is different
        for(ScheduleEntry entry in scheduleProvider.schedule.entries){
          String code = entry.roomLocation.split(' ')[0];
          Building? building = appState.findBuildingFromCode(code);
          if(building != null){
            uri += '${building.longitude.toString()},${building.latitude};';
          }
        }
        uri = uri.substring(0, uri.length - 1);
        uri += '?overview=full&geometries=geojson';
        final response = await fallbackClient.get(Uri.parse(uri));
        final parsedResponse = (jsonDecode(response.body));
        final List<dynamic> coordinates = parsedResponse['routes'][0]['geometry']['coordinates'];

        List<LatLng> points = coordinates.map(
          (point) {
            double longitude = (point[0] as num).toDouble();
            double latitude = (point[1] as num).toDouble();
            return LatLng(latitude, longitude);
          }
        ).toList();

        if(context.mounted){
          appState.setCoordinates(points);
          appState.changeTab(0);
        }
      } catch (e2) {
        //If both do not work print out the depub message below with error
        debugPrint('Both routing services failed: $e');
      }
    }
}