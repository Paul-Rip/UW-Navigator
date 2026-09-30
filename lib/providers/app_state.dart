import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/building.dart';
import '../models/class_schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  List<Building> _buildings = [];
  Building? _selectedBuilding;
  final List<ClassSchedule> _classes = [];
  double? _userLatitude;
  double? _userLongitude;
  List<String> _savedBuildingIds = [];
  List<LatLng> _coordinates = [];
  String _walkingTime = '';
  int currentIndex = 0;

  List<Building> get buildings => _buildings;
  Building? get selectedBuilding => _selectedBuilding;
  List<ClassSchedule> get classes => _classes;
  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;
  List<String> get savedBuildingIds => _savedBuildingIds;
  List<LatLng> get coordinates => _coordinates;
  String get walkingTime => _walkingTime;

  List<Building> get savedBuildings =>
      _buildings.where((b) => _savedBuildingIds.contains(b.name)).toList();

  bool isSaved(Building building) => _savedBuildingIds.contains(building.name);

  //Loads list of buildings from the buildings.json asset file into the provider
  //Parameters:
  //  - buildings: First Variable List of Building
  //No Returns
  void loadBuildings(List<Building> buildings) {
    _buildings = buildings;
    notifyListeners();
  }

  //Selects the building passed in and clears any existing route coordinates
  //Parameters:
  //  - building: First Variable Nullable Building
  //No Returns
  void selectBuilding(Building? building) {
    _selectedBuilding = building;
    _coordinates = [];
    _walkingTime = '';
    notifyListeners();
  }

  //Updates the stored user GPS coordinates
  //Parameters:
  //  - lat: First Variable double latitude
  //  - lng: Second Variable double longitude
  //No Returns
  void updateUserLocation(double lat, double lng) {
    _userLatitude = lat;
    _userLongitude = lng;
    notifyListeners();
  }

  void addClass(ClassSchedule classSchedule) {
    _classes.add(classSchedule);
    notifyListeners();
  }

  void removeClass(String id) {
    _classes.removeWhere((c) => c.courseCode == id);
    notifyListeners();
  }

  //Loads the list of saved building names from SharedPreferences on app start
  //No Parameters
  //Returns Future that completes when saved buildings are loaded
  Future<void> loadSavedBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    _savedBuildingIds = prefs.getStringList('saved_buildings') ?? [];
    notifyListeners();
  }

  //Toggles the saved state of a building and persists to SharedPreferences
  //Parameters:
  //  - building: First Variable Building
  //No Returns
  Future<void> toggleSaveBuilding(Building building) async {
    final prefs = await SharedPreferences.getInstance();
    if (_savedBuildingIds.contains(building.name)) {
      _savedBuildingIds.remove(building.name);
    } else {
      _savedBuildingIds.add(building.name);
    }
    await prefs.setStringList('saved_buildings', _savedBuildingIds);
    notifyListeners();
  }

  //Finds a building in the list by its abbreviation code
  //Parameters:
  //  - code: First Variable String building abbreviation (e.g. CSE2, MGH)
  //Returns the Building if found, null otherwise
  Building? findBuildingFromCode(String code){
    Building? building;
    //_buildings.firstWhereOrNull((curr) => curr.abbreviations.trim() == code.trim());
    for(Building b in _buildings){
      if(b.abbreviations == code){
        building = b;
      }
    }
    return building;
  }

  //Sets the route coordinates without a walking time (used for multi-building routes)
  //Parameters:
  //  - points: First Variable List of LatLng route coordinates
  //No Returns
  void setCoordinates(List<LatLng> points){
    _coordinates = points;
    _walkingTime = '';
    notifyListeners();
  }

  //Sets the route coordinates and calculates walking time from duration
  //Parameters:
  //  - points: First Variable List of LatLng route coordinates
  //  - durationSeconds: Second Variable double duration in seconds from routing API
  //No Returns
  void setRouteData(List<LatLng> points, double durationSeconds) {
    _coordinates = points;
    final minutes = (durationSeconds / 60).ceil();
    _walkingTime = '$minutes min walk';
    notifyListeners();
  }

  //Changes the currently active tab in the bottom navigation bar
  //Parameters:
  //  - num: First Variable int tab index (0=Map, 1=Schedule, 2=Search, 3=Saved)
  //No Returns
  void changeTab(int num){
    currentIndex = num;
    notifyListeners();
  }
}