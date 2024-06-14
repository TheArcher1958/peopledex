import 'package:flutter/material.dart';
import 'View/contact_list_screen.dart';
import 'View/upcoming_events_screen.dart';

void main() {
  runApp(PeopledexApp());
}

class PeopledexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peopledex',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ValueNotifier<bool> _needsReload = ValueNotifier<bool>(true);

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      ContactListScreen(needsReloadNotifier: _needsReload),
      UpcomingEventsScreen(needsReloadNotifier: _needsReload),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _needsReload.value = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Upcoming Events',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
