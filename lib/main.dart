import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uw_navigator/providers/position_provider.dart';
import 'package:uw_navigator/providers/schedule_provider.dart';
import 'package:uw_navigator/screens/schedule_screen.dart';
import 'package:uw_navigator/screens/search_screen.dart';
import 'package:uw_navigator/screens/saved_screen.dart';
import 'providers/app_state.dart';
import 'screens/map_screen.dart';

//Root widget of the UW Navigator app
//Sets up MultiProvider with AppState, PositionProvider, and ScheduleProvider
//and loads saved data from database and SharedPreferences before launching
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final scheduleProvider = ScheduleProvider();
  await scheduleProvider.loadFromDatabase();

  final appState = AppState();
  await appState.loadSavedBuildings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appState),
        ChangeNotifierProvider(create: (_) => PositionProvider()),
        ChangeNotifierProvider(create: (_) => scheduleProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UW Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6F00)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).addListener(_onTabChange);
    });
  }

  //Listener callback that syncs the PageController when AppState changes the active tab
  //Called whenever AppState.changeTab is invoked from schedule or search screens
  //No Parameters
  //No Returns
  void _onTabChange() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentIndex != _currentIndex) {
      setState(() => _currentIndex = appState.currentIndex);
      _pageController.animateToPage(
        appState.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    Provider.of<AppState>(context, listen: false).removeListener(_onTabChange);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          Provider.of<AppState>(context, listen: false).changeTab(index);
        },
        children: const [
          MapScreen(),
          ScheduleScreen(),
          SearchScreen(),
          SavedScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          Provider.of<AppState>(context, listen: false).changeTab(index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF6F00),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Saved'),
        ],
      ),
    );
  }
}