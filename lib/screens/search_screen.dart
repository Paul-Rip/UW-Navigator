import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/building.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Academic', 'Library', 'Dining', 'Recreation'];

  //Filters the buildings list based on the current search query and selected filter chip
  //Checks both building name and abbreviation against the search query
  //Parameters:
  //  - buildings: First Variable List of Building to filter
  //Returns the filtered list of buildings matching search and filter criteria
  List<Building> _filterBuildings(List<Building> buildings) {
    return buildings.where((building) {
      final matchesSearch = building.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          building.abbreviations
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' ||
          building.type.toLowerCase() == _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  //Builds the search screen with a search bar, filter chips, result count, and building list
  //Filters update in real time as the user types via setState on the search field
  //Parameters:
  //  - context: First Variable BuildContext
  //Returns the search screen scaffold described above
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final filtered = _filterBuildings(appState.buildings);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search buildings...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: const Color(0xFFFF6F00),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} building${filtered.length == 1 ? '' : 's'} found',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          ),

          // Building list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No buildings found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final building = filtered[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Color(0xFFFF6F00),
                        ),
                        title: Text(
                          building.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(building.hours),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          appState.selectBuilding(building);
                          // Switch to map tab
                          DefaultTabController.maybeOf(context)?.animateTo(0);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}