import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  //Builds the saved screen showing a list of buildings the user has starred
  //Shows empty state message if no buildings have been saved
  //Parameters:
  //  - context: First Variable BuildContext
  //Returns the saved screen with list or empty state
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final savedBuildings = appState.savedBuildings;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)
        ),
      ),
      body: savedBuildings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text(
                    'No saved places yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap the star icon on any building\nto save it for quick access.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: savedBuildings.length,
              itemBuilder: (context, index) {
                final building = savedBuildings[index];
                return Semantics(
                  label: '${building.name}, ${building.hours}. Tap to view on map.',
                  button: true,
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Color(0xFFFF6F00),
                    ),
                    title: Text(
                      building.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(building.hours),
                    trailing: IconButton(
                      icon: const Icon(Icons.star, color: Color(0xFFFF6F00)),
                      onPressed: () => appState.toggleSaveBuilding(building),
                    ),
                    onTap: () {
                      appState.selectBuilding(building);
                    },
                  ),
                );
              },
            ),
    );
  }
}