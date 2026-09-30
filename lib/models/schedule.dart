import 'package:flutter/material.dart';
import 'package:uw_navigator/models/schedule_entry.dart';


class Schedule {

  //Copied most things from Paul R's Journal app

  //Private List ScheduleEntry _entries that holds the JournalEntries in the journal
  late List<ScheduleEntry> _entries;

  //Constructor Journal that initializes _database and _entries
  //Parameters:
  //  - entries: Named Parameter Nullable List of ScheduleEntry
  //  - database: Required Named Parameter JournalDatabase
  Schedule(
    {List<ScheduleEntry>? entries}):
    _entries = entries ?? [];

  //Getter function that returns a copy of the entries list
  List<ScheduleEntry> get entries => _entries;

  //Updates the entry in the journal that was passed in
  //Parameters:
  //  - entry: First Variable ScheduleEntry
  //  - newContent: Named Parameter String
  //  - priority: Named Parameter int
  //  - newDescription: Named Parameter String
  //No Returns
  void updateEntry(
    ScheduleEntry entry, 
    {TimeOfDay newStartTime = const TimeOfDay(hour: 0, minute: 0),
    TimeOfDay newEndTime = const TimeOfDay(hour: 0, minute: 0),
    String newClassCode = '',
    String newClassDescription = '',
    String newRoomLocation = ''}){
    //These if statements check if the values are default
    //if they are sets it to the journal original values
    if(newStartTime == const TimeOfDay(hour: 0, minute: 0)){
      newStartTime = entry.startTime;
    }
    if(newEndTime == const TimeOfDay(hour: 0, minute: 0)){
      newEndTime = entry.endTime;
    }
    if(newClassCode == ''){
      newClassCode = entry.classCode;
    }
    if(newClassDescription == ''){
      newClassDescription = entry.classDescription;
    }
    if(newRoomLocation == ''){
      newRoomLocation = entry.roomLocation;
    }
    _entries = _entries.map((e) {
      if(e.id == entry.id){
        return ScheduleEntry.updateEntry(
          e,
          newStartTime: newStartTime,
          newEndTime: newEndTime,
          newClassCode: newClassCode,
          newClassDescription: newClassDescription,
          newRoomLocation: newRoomLocation
        );
      }
       return e;
    }).toList();
  }

  //Add an entry with the given values to journal
  //Parameters:
  //  - content: Named Parameter String
  //  - priority: Named Parameter int
  //  - description: Named Parameter String
  //No Returns
  void addEntry(
    {TimeOfDay newStartTime = const TimeOfDay(hour: 0, minute: 0),
    TimeOfDay newEndTime = const TimeOfDay(hour: 0, minute: 0),
    String newClassCode = '',
    String newClassDescription = '',
    String newRoomLocation = ''}){
    
    _entries.add(ScheduleEntry.fromText(
      classCode: newClassCode, 
      classDescription: newClassDescription, 
      startTime: newStartTime, 
      endTime: newEndTime, 
      roomLocation: newRoomLocation));
  }

  //Removes the given entry from the journal
  //Parameters:
  //  - entry: First Variable ScheduleEntry
  //No Returns
  void removeEntry(ScheduleEntry entry){
    _entries.remove(entry);
  }

  // Adds entry directly preserving original ID (used for undo/redo)
  void addEntryDirectly(ScheduleEntry entry) {
    _entries.add(entry);
  }
}