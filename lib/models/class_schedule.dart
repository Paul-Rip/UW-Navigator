import 'package:flutter/material.dart';

//Data structure that holds all the information about a class schedule entry
//Used as a legacy model kept for reference but ScheduleEntry is the primary model
class ClassSchedule {
  final String courseCode;
  final String courseName;
  final String buildingId;
  final String roomNumber;
  final List<String> days;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  //Constructor that assigns all required fields to the ClassSchedule variables
  //Parameters:
  //  - courseCode: Named Required String
  //  - courseName: Named Required String
  //  - buildingId: Named Required String
  //  - roomNumber: Named Required String
  //  - days: Named Required List of String
  //  - startTime: Named Required TimeOfDay
  //  - endTime: Named Required TimeOfDay
  //No Returns
  ClassSchedule({
    required this.courseCode,
    required this.courseName,
    required this.buildingId,
    required this.roomNumber,
    required this.days,
    required this.startTime,
    required this.endTime,
  });

  //Factory constructor that creates a ClassSchedule from a JSON map
  //Parameters:
  //  - json: First Variable Map of String to dynamic
  //Returns a ClassSchedule with all fields populated from the JSON data
  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      courseCode: json['courseCode'] as String,
      courseName: json['courseName'] as String,
      buildingId: json['buildingId'] as String,
      roomNumber: json['roomNumber'] as String,
      days: List<String>.from(json['days'] as List),
      startTime: TimeOfDay(
        hour: json['startHour'] as int,
        minute: json['startMinute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['endHour'] as int,
        minute: json['endMinute'] as int,
      ),
    );
  }

  //Converts the ClassSchedule to a JSON map for serialization
  //No Parameters
  //Returns a Map of String to dynamic representing the ClassSchedule
  Map<String, dynamic> toJson() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'buildingId': buildingId,
      'roomNumber': roomNumber,
      'days': days,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
    };
  }
}