Identify which of the course topics you applied (e.g. secure data persistence) and describe how you applied them. In addition to the list of topics enumerated above, you must also describe how your app design reflects what you learned about the design principles we discussed in our Inclusive Design lecture (Lecture 9: Designing for Accessibility)

The course topics that we applied include Stateful widgets, Navigation (Stack and Bar), Providers, Asynchronous functions, Timers, and APIs. These are the course themes that we could think of that we utilized in the creation of our project. We will go left to right starting with stateful widgets.
We utilized stateful widgets in search, map, edit schedule, and add schedule screens since in these screens there is generally user input that is dynamically changing or something where a stateful widget is useful.
We utilized the navigation bar to switch between our 4 main areas map, schedule, search, and saved and the navigation stack is utilized within the schedule screen when the user wants to either edit or add a schedule entry.
Providers were used to send various information through the different files and we used three those being app state, position provider, and schedule provider. The providers allowed for the transfer of coordinates from schedule to map and the transfer of building information between files through app state.
Asynchronous functions were used throughout the project especially within the providers and most prominent in loading the data from the database. Async functions are also present in several of the buttons on press functions since for some of them especially within schedule screen and add/edit schedule screens.
Timer was used within the position provider geolocation so that there was a consistent updating of location so that if the person moved they would not be inhibited by their marker being stuck in one location.
We utilized an API call for the Open Source Routing Machine or Valhalla that gave the routing information we needed to be able to plot it onto a map.

The six required techniques we applied are as follows:

1. Accessing Phone Sensors (GPS): We accessed the phones GPS sensor using the geolocator package within the position provider. A timer fires every second and calls getCurrentPosition which updates the users latitude and longitude in real time. This is what drives the location marker on the map and provides the starting point for all of our routing API calls.

2. Querying Web Services (APIs): We call two external routing APIs in our app. Valhalla is our primary routing engine and uses a pedestrian costing model with walkway preference settings we tuned to better follow campus paths. OSRM serves as a fallback if Valhalla fails for any reason. Both return encoded route coordinates that we decode and store in app state to be drawn on the canvas.

3. Drawing with Canvas: The RoutePainter in lib/widgets/route_painter.dart extends CustomPainter and uses Flutters Canvas and Path API to draw the walking route on the map. We call path.moveTo on the first GPS coordinate and path.lineTo through each subsequent point then canvas.drawPath to render the orange route line. We also draw start and destination circles using canvas.drawCircle. The shouldRepaint method returns true when routePoints changes which is triggered by a mapEventStream listener that forces repaints on every pan and zoom event so the route stays locked to the map.

4. Gesture Detection: We implemented four gestures beyond onTap. Swiping between tabs using PageView with PageController, pinch to zoom on the map via InteractiveFlag.all in flutter_maps MapOptions, panning to drag the map also via InteractiveFlag.all, and long press to drop a custom red pin via MapOptions.onLongPress. The combination of pan gestures with the other interaction methods satisfies the spec requirement for combining onPan methods with other gesture types.

5. Undo and Redo: The ScheduleProvider keeps two List of ScheduleAction stacks, like Google Docs behavior. When addEntry or removeEntry is called, ScheduleProvider pushes an action to the undo stack, and clears the redo stack. When undo is called, ScheduleProvider pops an action off the undo stack, and applies the inverse operation, and pushes to the redo stack. When redo is called, ScheduleProvider pops an action off the redo stack, and applies the inverse operation, and pushes to the undo stack. This allows for unlimited sequential undos and redos for add and delete operations.

6. Data Persistence: We use two persistence mechanisms. SQLite via sqflite in the DatabaseService persists the class schedule where entries are saved on creation, updated on edit, and deleted on removal. SharedPreferences in AppState persists saved buildings by name. Both are loaded in main before the app starts so all user data survives app restarts.

Our app design reflects what we learned about design principles by implementing the accessibility features mentioned in Lecture 9: Designing for Accessibility including using high contrast so things are readable, utilizing alternative text for buttons and other interactive elements, making state changes obvious to the user, and avoiding blue as a primary action color since it can be hard to distinguish for some users.

Cite anything (website or other resource) or anyone that assisted you in creating your solution to this assignment, Remember to include all resources you used to solve this assignment.
You do not need to include links to lecture/section material or flutter docs. However you do need to mention which Flutter classes or packages you viewed.
You must include links to all StackOverflow, Medium, blogs, or other articles you used.
If you used any Generative AI (ChatGPT, Gemini, CodePilot, or the like), please include the prompt(s) you used and how the result was or was not helpful.
If you did not use any resources beyond classroom/flutter docs, please state so explicitly.

AI Prompts to Gemini (no particular order):

how to pass provider into another flutter file
decode polyline in flutter
Another exception was thrown: RangeError (length): Invalid value: Valid value range is empty: 0
Another exception was thrown: Tried to listen to a value exposed with provider, from outside of the widget tree.

AI Prompts to Claude (no particular order):

Error connecting to the service protocol: failed to connect to http://127.0.0.1:55964/MMC0yosMtTY=/ HttpException: Connection closed before full
header was received, uri = http://127.0.0.1:55964/MMC0yosMtTY=/ws (plus code)
Additional prompts in long_prompts.md they are just two long error messages put in as a prompt

Implementing AutomaticKeepAliveClientMixin to fix the LateInitializationError when returning to the map tab
Setting up SharedPreferences for persisting saved buildings across app restarts

All the prompts in both Gemini and Claude were all helpful whether it helped directly with showing me an example of a code with and without the error or it helped me indirectly by explaining to me what the error is or what are some possible ways to fix it without any code. Claude was generally helpful for debugging specific errors and providing code structure.

https://pub.dev/packages/flutter_polyline_points (Polyline)
https://pub.dev/packages/flutter_map_location_marker (CurrentLocationLayer)
https://api.flutter.dev/flutter/painting/RoundedRectangleBorder-class.html (RoundedRectangleBorder)
https://api.flutter.dev/flutter/dart-core/String/split.html (split string)
https://project-osrm.org/docs/v5.5.1/api/#general-options (OSRM docs)
https://valhalla.github.io/valhalla/api/turn-by-turn/api-reference/#inputs-of-a-route (Valhalla docs)

Discuss how doing this project challenged and/or deepened each of your understanding of the technical methods or topics relevant to your project, including the six (or more) required techniques you used

The project challenged us by having us dive deeper into the concepts of this course and exploring the topics on our own. An example of this is with the API call we found an online API that does routing but we had to work around our variable especially for the longitude and latitude and learn about how the API functioned. We also dove deeper into the geolocator by utilizing it within our map for routing and displaying the current location on the map. Our knowledge of interactions betweens providers and other files deepened since we utilized several different providers to process our data and it helped us learn the interaction of providers between files and especially with stateless and stateful widgets.

For Ariel, the most challenging part was the canvas drawing. Understanding how CustomPainter integrates with a live map was different from a static canvas because the map underneath is constantly changing position as the user pans and zooms. I learned that MapController.latLngToScreenPoint converts geographic coordinates to screen pixels but those pixels shift every time the map moves. Solving this required listening to mapController.mapEventStream and calling setState on every map event to force the canvas to recalculate its screen positions. This deepened my understanding of Flutters rendering cycle and the relationship between setState, CustomPainter, and shouldRepaint.

Describe what changed from your original concept to your final implementation and explain why your group made those changes from your original design vision. 

The original concept of the redo button was to allow for a single schedule entry that was just deleted to be redoed/undeleted. This was changed to implement a undo and redo button similar to google docs that allow for an "infinite" amount of undos and redos. The reason we decided to implement this change instead was to give the user more authority over their schedule meaning they can control their schedule beter like if they decide to readd a class to their schedule.

Describe two areas of future work for your app

The first item of future work would be figuring out how to get interior mapping of buildings since it seemed that was something people wanted and found would be useful when navigating around campus.

The second item would be to create a notification system to alert users of upcoming classes and allow them to click on the notification to directly navigate to the building their next class is in.