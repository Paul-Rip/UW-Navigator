import 'package:flutter/material.dart';
import 'package:uw_navigator/models/schedule_entry.dart';

class AddScheduleScreen extends StatefulWidget{

  const AddScheduleScreen({super.key});

  @override 
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen>{

  //Text controllers for recieving user inputted data
  
  //Controller that is responsible for class code
  final controller = TextEditingController();
  //Controller that is responsible for class description
  final controller2 = TextEditingController();
  //Controller that is responsible for room location
  final controller3 = TextEditingController();
  //Controller that is responsible for start time
  final controller4 = TextEditingController();
  //Controller that is responsible for end time
  final controller5 = TextEditingController();
  //default time for start time and end time of class
  TimeOfDay? startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay? endTime = const TimeOfDay(hour: 0, minute: 0);

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

  //Creates the add entry view that allows the user to create their class
  //with inputs for class code, description, roomlocation, start and end time
  //Parameters:
  //  - context: First Variable BuildContext
  //Returns the page that has the user create their class then pops
  //back class with information entered (and default values if not inputted)
  //if submit button is clicked
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class'),
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
      floatingActionButton: Semantics(
        label: 'Submit',
        button: true,
        child: TextButton(
          //If submit button is pressed creates a new entry
          onPressed: () {
            final ScheduleEntry entry = ScheduleEntry.fromText(
              classCode: controller.text,
              classDescription: controller2.text,
              roomLocation: controller3.text,
              startTime: startTime ?? const TimeOfDay(hour: 0, minute: 0),
              endTime: endTime ?? const TimeOfDay(hour: 0, minute: 0),
            );
            //pops back that new entry with values inputted and
            //default values if field is blank
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
