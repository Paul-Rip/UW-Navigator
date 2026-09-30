import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PositionProvider extends ChangeNotifier {
  // latitude of current location default of allen building
  double latitude = 47.96649; 
  // longitude of current location default of allen building
  double longitude = -122.34318;
  // Stores if location was sucessfully loaded
  bool hasLocation = false;
  // Acts as a lock for the timer refresh
  bool _isRequesting = false;

  // Constructor that initialize the position checker that updates current position every second
  // No Parameters
  // No returns
  PositionProvider(){
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updatePoisition()
    );
  }

  // Updates the current latitude and longitude from GPS if not already requesting
  // Skips if a position request is already in progress to prevent overlapping calls
  // No Parameters
  // No Returns
  void _updatePoisition() async {
    if (_isRequesting) return; // skip if already requesting
    _isRequesting = true;
    try {
      final Position position = await _determinePosition();
      latitude = position.latitude;
      longitude = position.longitude;
      notifyListeners();
    } catch (e) {
      // silently ignore errors
    } finally {
      _isRequesting = false;
    }
  }

  // Determine the current position of the device.
  // When the location services are not enabled or permissions
  // are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 
    //added the assignmentment of hasLocation to true here because if we got here
    //there are no errors with getting the current position
    hasLocation = true;
    return await Geolocator.getCurrentPosition();
  }
}