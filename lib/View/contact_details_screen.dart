import 'package:flutter/material.dart';
import '../Controller/database_helper.dart';
import '../Modal/models.dart' as models;
import 'add_contact_screen.dart';
import 'add_note_screen.dart';

class ContactDetailsScreen extends StatefulWidget {
  final models.Contact contact;

  ContactDetailsScreen({required this.contact});

  @override
  _ContactDetailsScreenState createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  final dbHelper = DatabaseHelper();
  late models.Contact _contact;
  late Future<List<models.Note>> _notes;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
    _notes = Future.value([]); // Initialize with an empty list
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final updatedNotes = await dbHelper.getNotesForContact(_contact.id!);
    setState(() {
      _notes = Future.value(updatedNotes);
    });
  }

  Future<void> _refreshContact() async {
    final updatedContact = await dbHelper.getContactById(_contact.id!);
    setState(() {
      if (updatedContact != null) {
        _contact = updatedContact;
      }
      _refreshNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddContactScreen(contact: _contact),
                ),
              );
              _refreshContact(); // Refresh the contact after editing
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Birthday: ${_contact.birthday}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Relationship: ${_contact.relationship}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Interests: ${_contact.interests}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Notes:', style: TextStyle(fontSize: 18)),
            FutureBuilder<List<models.Note>>(
              future: _notes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No notes found.'));
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final note = snapshot.data![index];
                        return ListTile(
                          title: Text(note.text),
                          subtitle: Text(note.date),
                          trailing: note.isReminder ? Icon(Icons.alarm) : null,
                          onTap: () {
                            // Handle note tap (e.g., edit note)
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(
                preselectedContacts: [_contact], // Pass the selected contact here
              ),
            ),
          );
          _refreshNotes();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
