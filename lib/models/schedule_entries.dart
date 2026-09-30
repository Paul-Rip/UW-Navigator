import 'package:drift/drift.dart';

class ScheduleEntries extends Table{

  //class code of the class ex. CSE 340
  TextColumn get classCode => text()();

  //class description of the class ex. Interactive Programming
  TextColumn get classDescription => text()();

  //id created for each class for internal use only
  IntColumn get id => integer().autoIncrement()();

  //start time of the class
  TextColumn get startTime => text()();

  //end time of the class
  TextColumn get endTime => text()();

  //room location of the class ex. CSE2 G10
  TextColumn get roomLocation => text()();
}