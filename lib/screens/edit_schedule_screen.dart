import 'package:flutter/material.dart';
import 'package:uw_navigator/models/schedule_entry.dart';

class EditScheduleScreen extends StatefulWidget{

  final ScheduleEntry? entry;

  const EditScheduleScreen({super.key, required this.entry});

  @override 
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen>{

  //Controller that is responsible for class code
  late TextEditingController controller;
  //Controller that is responsible for class description
  late TextEditingController controller2;
  //Controller that is responsible for room location
  late TextEditingController controller3;
  //Controller that is responsible for start time
  late TextEditingController controller4;
  //Controller that is responsible for end time
  late TextEditingController controller5;
  //nullable start time and end time of class
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  //Sets the initial state of all of the controllers
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.entry?.classCode);
    controller2 = TextEditingController(text: widget.entry?.classDescription);
    controller3 = TextEditingController(text: widget.entry?.roomLocation);
    //Need to extract hours, minutes, and check if am or pm for start and end time texts
    controller4 = TextEditingController(text: (
      '${widget.entry?.startTime.hourOfPeriod.toString()}:'
      '${widget.entry?.startTime.minute.toString().padLeft(2, '0')} '
      '${widget.entry?.startTime.period == DayPeriod.am ? 'AM' : 'PM'}'));
    controller5 = TextEditingController(text: (
      '${widget.entry?.endTime.hourOfPeriod.toString()}:'
      '${widget.entry?.endTime.minute.toString().padLeft(2, '0')} '
      '${widget.entry?.endTime.period == DayPeriod.am ? 'AM' : 'PM'}'));
  }

  //Disposes of the controllers after they are done with
  //No parameters
  //No returns
  @override
  void dispose() {
    controller.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    controller5.dispose();
    super.dispose();
  }

  //Creates the edit entry view that allows the user to edit any
  //part of their class that they want to
  //Parameters:
  //  - context: First Variable BuildContext
  //Returns the page that contains all the information
  //the user has inputted into the entry and allows them to edit them
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Class Code (e.g. CSE 340)',
              ),
              maxLength: 10,
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: controller2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Class Description (e.g. Interactive Programming)',
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: controller3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Room Location (e.g. CSE2 G10)',
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: controller4,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Choose Start Time'
              ),
              onTap: () async {
                startTime = await 
                //Makes it so can only input hours and minutes
                showTimePicker(
                  context: context, 
                  initialTime: TimeOfDay.now());
                if(startTime != null && context.mounted){
                  controller4.text = startTime!.format(context);
                }
              },
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: controller5,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Choose End Time'
              ),
              onTap: () async {
                endTime = await 
                //Makes it so can only input hours and minutes
                showTimePicker(
                  context: context, 
                  initialTime: TimeOfDay.now());
                if(endTime != null && context.mounted){
                  controller5.text = endTime!.format(context);
                }
              },
            ),
          ],
        ),
      ),
      //Submit button that returns the edited entry if any
      floatingActionButton: Semantics(
        label: 'Submit',
        button: true,
        child: TextButton(
          onPressed: () {
            final ScheduleEntry entry = ScheduleEntry.updateEntry(
              widget.entry!,
              newClassCode: controller.text,
              newClassDescription: controller2.text,
              newRoomLocation: controller3.text,
              newStartTime: startTime ?? widget.entry!.startTime,
              newEndTime: endTime ?? widget.entry!.endTime,
            );
            //pops the entry back to the main schedule screen
            Navigator.pop(context, entry);
            }, 
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.padded,
            minimumSize: WidgetStatePropertyAll<Size>(Size(100, 50)),
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.black),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20
            ),
          ),
        ),
      )
    );
  }
}
