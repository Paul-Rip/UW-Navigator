class Building {
  final String name;
  final String abbreviations;
  final String hours;
  final double latitude;
  final double longitude;
  final bool elevators;
  final bool accessible;
  final String type;

  //Data structure that holds all information about a UW campus building
  //Parsed from buildings.json and used throughout the app for map markers,
  //routing, search, and saved buildings
  Building({
    required this.name,
    required this.abbreviations,
    required this.hours,
    required this.latitude,
    required this.longitude,
    required this.elevators,
    required this.accessible,
    this.type = 'academic',
  });

  //Constructor that assigns all fields to the Building variables
  //Parameters:
  //  - name: Named Required String
  //  - abbreviations: Named Required String
  //  - hours: Named Required String
  //  - latitude: Named Required double
  //  - longitude: Named Required double
  //  - elevators: Named Required bool
  //  - accessible: Named Required bool
  //  - type: Named Optional String defaulting to academic
  //No Returns
  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      name: json['name'] as String,
      abbreviations: json['abbreviations'] as String,
      hours: json['hours'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      elevators: json['elevators'] as bool,
      accessible: json['accessible'] as bool,
      type: json['type'] as String? ?? 'academic',
    );
  }
}