import 'package:flutter/material.dart';

class ScheduleEntry {

  final String classCode;

  //internal id of the class
  final int id;

  final String classDescription;

  final TimeOfDay startTime;

  final TimeOfDay endTime;

  final String roomLocation;

  //factory constructor that intialize all variables with their respective items
  //Parameters:
  //  - text: Named parameter default value empty string
  //Returns JounalEntry with inputted text and other values associated with the entry
  factory ScheduleEntry.fromText(
    {required String classCode, 
    required String classDescription,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String roomLocation}) {
    return ScheduleEntry(
        classCode: classCode,
        id: SequentialIDMaker.nextID(),
        classDescription: classDescription,
        startTime: startTime,
        endTime: endTime,
        roomLocation: roomLocation);
  }

  //normal constructor tht assigns values to the ScheduleEntry variables
  //Also can update the text of the journal entry to a new text value
  //Parameters:
  //  text: Named variable String
  //  id: Named variable int
  //  updatedAt: Named variable DateTime
  //  createdAt: Named variable DateTime
  //No returns
  ScheduleEntry(
      {required this.classCode,
      required this.id,
      required this.classDescription,
      required this.startTime,
      required this.endTime,
      required this.roomLocation});

  ScheduleEntry.updateEntry(ScheduleEntry entry, 
      {
        TimeOfDay newStartTime = const TimeOfDay(hour: 0, minute: 0),
        TimeOfDay newEndTime = const TimeOfDay(hour: 0, minute: 0),
        String newClassCode = '',
        String newClassDescription = '',
        String newRoomLocation = ''
      })
      : id = entry.id,
        startTime = newStartTime,
        endTime = newEndTime,
        classCode = newClassCode,
        classDescription = newClassDescription,
        roomLocation = newRoomLocation;
}

//returns a new id that is one above the previous id used
//No parameter
//Returns the int id that was created
class SequentialIDMaker {
  static int _lastID = 0;
  static int nextID() {
    _lastID += 1;
    return _lastID;
  }
}
