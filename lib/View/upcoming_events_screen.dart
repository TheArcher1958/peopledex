import 'package:flutter/material.dart';
import '../Controller/database_helper.dart';
import '../Modal/models.dart' as models;

class UpcomingEventsScreen extends StatefulWidget {
  final ValueNotifier<bool> needsReloadNotifier;

  UpcomingEventsScreen({required this.needsReloadNotifier});

  @override
  _UpcomingEventsScreenState createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<dynamic>> upcomingEvents; // Change the type to dynamic to handle both notes and contacts

  @override
  void initState() {
    super.initState();
    upcomingEvents = _loadUpcomingEvents();
  }

  Future<List<dynamic>> _loadUpcomingEvents() async {
    List<models.Note> notes = await dbHelper.getAllNotes();
    List<models.Contact> contacts = await dbHelper.getContacts();
    DateTime now = DateTime.now();

    // Create a combined list of events and birthdays
    List<dynamic> events = [];

    // Add notes to the list
    for (var note in notes) {
      events.add({
        'type': 'note',
        'date': DateTime.parse(note.date),
        'data': note,
      });
    }

    // Add upcoming birthdays to the list
    for (var contact in contacts) {
      DateTime? birthday = _safeParseDate(contact.birthday);
      if (birthday != null) {
        DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);
        if (nextBirthday.isBefore(now)) {
          nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
        }
        events.add({
          'type': 'birthday',
          'date': nextBirthday,
          'data': contact,
        });
      }
    }

    // Sort the list by date
    events.sort((a, b) => a['date'].compareTo(b['date']));

    return events;
  }

  DateTime? _safeParseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Events'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: upcomingEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No upcoming events found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var event = snapshot.data![index];
                if (event['type'] == 'birthday') {
                  models.Contact contact = event['data'];
                  return ListTile(
                    title: Text(contact.name),
                    subtitle: Text('Birthday: ${event['date'].toLocal()}'),
                  );
                } else {
                  models.Note note = event['data'];
                  return ListTile(
                    title: Text(note.text),
                    subtitle: Text('Due: ${event['date'].toLocal()}'),
                    trailing: note.isReminder ? Icon(Icons.alarm) : null,
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
