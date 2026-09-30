## Build Instructions

### Prerequisites
- Flutter SDK installed
- iOS device or simulator (Android works too)
- Internet connection (for routing API)
- Location services enabled on device

### Steps to Run
```bash
# 1. Clone the repository
git clone https://gitlab.cs.washington.edu/cse340-26sp-students/as-final-paulrip-ashani.git

# 2. Navigate to the app folder
cd "UW Navigator"

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

### API Keys
No API keys are required. This app uses:
- **Valhalla** (valhalla1.openstreetmap.de) - free, no key needed
- **OSRM** (router.project-osrm.org) - free, no key needed  
- **OpenStreetMap** tiles - free, no key needed

Briefly explain the purpose of your app, then explain how to build and run the app. Make sure to explain any dependencies, API keys, or other requirements that others (including the course teaching team) need to satisfy to compile and run your app.

The purpose of our app is to serve as a University of Washington Navigator that utilizes real time GPS positioning to help you navigate to different buildings. This app is mainly targeted at first year or transfer students. The goal is to provide a all in one solution to UW class navigation and timing meaning that in this app we will have a navigator to various UW buildings and a place to store your schedule even having a button that allows you to route your class schedule without needing to rush the day of classes or going a day early to figure out your routing for classes. This is meant to especially help with routing to buildings that are a bit distant from each other so students can optimize their routing so they do not miss out on learning time. The dependecies for this app include and internet connection (for http api call) and GPS location to be on so that map can route properly.

About This App:
This app is targeted at first year students or transfer students that can often times get lost around the UW campus. The app offers an all in one solution to solve this by having a schedule builder that can then create a route between your schedule buildings helping those students to be more equipped to navigate the campus of the first day of the quarter.

Requirements:
This app requires a couple things those being an internet connection so that the routing api http call is able to go through as well as location services so the routing is able to work with your current location when wanting to navigate to buildings.

Project Layout:
There are four distinct parts of the project. There is a navigation bar on the bottom of the screen to navigate going left to right we have map, schedule, search, and saved. Within the map screen we see a map with vaious markers on it that indicate the UW buildings that we have added to the project clicking on one of the pins you will see the building name, its hours, if it is wheel chair accessible, if it has elevators, and a navigate button. Pressing the navigate button will draw a route on the screen and give an estimate of how long in minutes the walk will take. The star Icon will save that building in the saved tab. Within the map you can also zoom in and out with the plus and minus while also having the ability to center your location on the map again with the button under the minus button. Moving to the schedule screen in the schedule screen there is an add plus button that allows for the addition of a class the add button push a screen that allows for you to enter in class code, class description, room location, and start and end times. Submitting will place the class onto the screen displaying all the information that was put into the entry. The entry can be added by clicking the class code at the top of the class container. The Navigate button within the class container when clicked creates a route on the map screen from the current location to the building with the class. The delete button removes the class and there are undo and redo buttons if needed. In the bottom right there is a create route schedule button that creates a route between all the buildings placed in the schedule. Moving to the search screen within this screen we can see the buildings that we added diplayed with their name and hours including filters for various options. Lastly the saved screen showcases the buildings that were saved with their name and hours.

Presentation slides are from UW Navigator folder simply named GROUP 7_ UW Navigator.pdf