import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';

class DatabaseService {
  static Database? _database;

  //Returns the singleton database instance, initializing it if needed
  //No Parameters
  //Returns Future Database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  //Initializes the SQLite database and creates the schedule table if it does not exist
  //No Parameters
  //Returns Future Database that was created or opened
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'uw_navigator.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE schedule (
            id INTEGER PRIMARY KEY,
            classCode TEXT,
            classDescription TEXT,
            startHour INTEGER,
            startMinute INTEGER,
            endHour INTEGER,
            endMinute INTEGER,
            roomLocation TEXT
          )
        ''');
      },
    );
  }

  //Loads all schedule entries from the SQLite database
  //No Parameters
  //Returns Future List of ScheduleEntry objects stored in the database
  Future<List<ScheduleEntry>> loadEntries() async {
    final db = await database;
    final maps = await db.query('schedule');

    return maps.map((map) {
      return ScheduleEntry(
        id: map['id'] as int,
        classCode: map['classCode'] as String,
        classDescription: map['classDescription'] as String,
        startTime: TimeOfDay(
          hour: map['startHour'] as int,
          minute: map['startMinute'] as int,
        ),
        endTime: TimeOfDay(
          hour: map['endHour'] as int,
          minute: map['endMinute'] as int,
        ),
        roomLocation: map['roomLocation'] as String,
      );
    }).toList();
  }

  //Saves a single schedule entry to the database, replacing if it already exists
  //Parameters:
  //  - entry: First Variable ScheduleEntry to save
  //No Returns
  Future<void> saveEntry(ScheduleEntry entry) async {
    final db = await database;
    await db.insert(
      'schedule',
      {
        'id': entry.id,
        'classCode': entry.classCode,
        'classDescription': entry.classDescription,
        'startHour': entry.startTime.hour,
        'startMinute': entry.startTime.minute,
        'endHour': entry.endTime.hour,
        'endMinute': entry.endTime.minute,
        'roomLocation': entry.roomLocation,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Deletes a schedule entry from the database by its id
  //Parameters:
  //  - id: First Variable int id of the entry to delete
  //No Returns
  Future<void> deleteEntry(int id) async {
    final db = await database;
    await db.delete('schedule', where: 'id = ?', whereArgs: [id]);
  }

  //Updates an existing schedule entry in the database with new values
  //Parameters:
  //  - entry: First Variable ScheduleEntry with updated values
  //No Returns
  Future<void> updateEntry(ScheduleEntry entry) async {
    final db = await database;
    await db.update(
      'schedule',
      {
        'classCode': entry.classCode,
        'classDescription': entry.classDescription,
        'startHour': entry.startTime.hour,
        'startMinute': entry.startTime.minute,
        'endHour': entry.endTime.hour,
        'endMinute': entry.endTime.minute,
        'roomLocation': entry.roomLocation,
      },
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }
}