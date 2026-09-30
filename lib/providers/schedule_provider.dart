import 'package:flutter/material.dart';
import 'package:uw_navigator/models/schedule.dart';
import 'package:uw_navigator/models/schedule_entry.dart';
import '../services/database_service.dart';

class _ScheduleAction {
  final bool wasAdded;
  final ScheduleEntry entry;
  _ScheduleAction({required this.wasAdded, required this.entry});
}

class ScheduleProvider extends ChangeNotifier {
  final Schedule _schedule = Schedule();
  final DatabaseService _db = DatabaseService();
  bool _loaded = false;

  // Google Docs style undo/redo stacks
  final List<_ScheduleAction> _undoStack = [];
  final List<_ScheduleAction> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  //Getter for the journal but sorts the entries first before grabbing journal
  Schedule get schedule {
    _schedule.entries.sort((one, two) {
      final aMinutes = one.startTime.hour * 60 + one.startTime.minute;
      final bMinutes = two.startTime.hour * 60 + two.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return _schedule;
  }

  // Call this once on app start to load saved entries
  Future<void> loadFromDatabase() async {
    if (_loaded) return;
    final entries = await _db.loadEntries();
    for (final entry in entries) {
      _schedule.entries.add(entry);
    }
    _loaded = true;
    notifyListeners();
  }

  //Updates the entry in the journal that was passed in
  //Parameters:
  //  - entry: First Variable JournalEntry
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
      String newRoomLocation = ''
    }) {
    
    _schedule.updateEntry(
      entry,
      newStartTime: newStartTime,
      newEndTime: newEndTime,
      newClassCode: newClassCode,
      newClassDescription: newClassDescription,
      newRoomLocation: newRoomLocation
    );

    // Find updated entry and save to database
    final updated = _schedule.entries.firstWhere((e) => e.id == entry.id);
    _db.updateEntry(updated);

    notifyListeners();
  }

  //Add an entry with the given values to journal
  //Parameters:
  //  - content: Named Parameter String
  //  - priority: Named Parameter int
  //  - description: Named Parameter String
  //No Returns
  void addEntry(
    {required String classCode, 
    required String classDescription,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String roomLocation}) {

    _schedule.addEntry(
      newClassCode: classCode,
      newClassDescription: classDescription,
      newEndTime: endTime,
      newRoomLocation: roomLocation,
      newStartTime: startTime);
    
    // Save to database
    _db.saveEntry(_schedule.entries.last);

    // Push to undo stack, clear redo (Google Docs behavior)
    _undoStack.add(_ScheduleAction(wasAdded: true, entry: _schedule.entries.last));
    _redoStack.clear();
    
    notifyListeners();
  }

  //Removes the given entry from the journal
  //Parameters:
  //  - entry: First Variable JournalEntry
  //No Returns
  void removeEntry(ScheduleEntry entry) {
    _db.deleteEntry(entry.id);
    _schedule.removeEntry(entry);
    
    // Push to undo stack, clear redo (Google Docs behavior)
    _undoStack.add(_ScheduleAction(wasAdded: false, entry: entry));
    _redoStack.clear();

    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();

    if (action.wasAdded) {
      _db.deleteEntry(action.entry.id);
      _schedule.removeEntry(action.entry);
      _redoStack.add(_ScheduleAction(wasAdded: true, entry: action.entry));
    } else {
      _schedule.addEntryDirectly(action.entry);
      _db.saveEntry(action.entry);
      _redoStack.add(_ScheduleAction(wasAdded: false, entry: action.entry));
    }
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();

    if (action.wasAdded) {
      _schedule.addEntryDirectly(action.entry);
      _db.saveEntry(action.entry);
      _undoStack.add(_ScheduleAction(wasAdded: true, entry: action.entry));
    } else {
      _db.deleteEntry(action.entry.id);
      _schedule.removeEntry(action.entry);
      _undoStack.add(_ScheduleAction(wasAdded: false, entry: action.entry));
    }
    notifyListeners();
  }
}