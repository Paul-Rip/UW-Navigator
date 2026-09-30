Data Design:

Position provider is our geolocator that utilizes the phones sensor to grab GPS coordinates.

Schedule provider is our provider that stores all of the schedule entries submitted by the user through the add entry screen. The provider also adds, removes, and updates the entries as necessary.

Schedule is the overall data structure that holds all of the schedule entries together and has the ability to add, remove, and update entries as needed it simply holds a list of schedule entries.

Schedule entry is the entry created from the add entry screen and contains the class code, description, room location, and start and end time. There are methods within schedule entry that create and update the entry depending on what is needed at the time of the call.

Building is the data structure that parses the buildings.json and grabs all the information and holds it so essentially it holds the json variables about the actual building data within a data structure to be used for the map or any other time we need building information.

App State is our central provider that acts as the single source of truth for the app. It holds the list of all buildings loaded from buildings.json, the currently selected building shown in the bottom sheet, the GPS route coordinates returned from the routing API, the walking time estimate, the list of saved building names persisted via SharedPreferences, and the current active tab index used to switch screens programmatically.

Data Flow:

Position provider updates its coordinates every second which then gets placed on the map screen and if needed put into the routing information. Whenever there is a change in the coordinates of the position provider then the consumer knows to repaint the location of the current coordinate marker.

The Schedule provider updates the schedule it has within itself when the user either adds, edits, or deletes and entry from schedule and these actions trigger the UI to change according to the change made by the user. After these changes it notifies its listeners to let them know to update their UI since something within the schedule has changed meaning an entry should be added, edited, or delted.

The Schedule and Schedule Entry work in a similar manner to the schedule provider since they fall under the schedule provider. So in essence both schedule and schedule entry are updated when the user adds, edits, or deletes an entry with a button the provider notifies the listeners so the schedule and schedule entry alone do not change the UI but combined with the provider the UI is updated when these changes are made.

Building never really changes so it does not really update UI in any sense and since it does not change there is no data flow within the data structure. The most we are doing with building are diplaying its values or checking it against another value so there is no data flow or UI updates in regards to Building.

App State bridges the gap between all other providers and screens. When a user taps a building marker, selectBuilding updates the selected building and clears the route, causing the bottom sheet Consumer to rebuild and show the new building. When the routing API returns coordinates, setRouteData stores them and triggers the MapScreen canvas to repaint the route. When a class Navigate button is tapped from ScheduleScreen, changeTab switches the active page and the route is drawn, demonstrating data flowing from the schedule system through AppState into the map system reactively.