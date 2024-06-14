import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../Controller/database_helper.dart';
import '../Modal/models.dart' as models;
import 'contact_selector.dart';  // Import the custom contact selector

class AddNoteScreen extends StatefulWidget {
  final models.Note? note;
  final List<models.Contact>? preselectedContacts;

  AddNoteScreen({this.note, this.preselectedContacts});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final dbHelper = DatabaseHelper();
  TextEditingController _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isReminder = false;
  String _eventType = "Contact";
  List<models.Contact> _selectedContacts = [];
  List<models.Contact> _allContacts = [];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _textController.text = widget.note!.text;
      _selectedDate = DateTime.parse(widget.note!.date);
      _isReminder = widget.note!.isReminder;
      _eventType = widget.note!.eventType;
      _loadSelectedContacts();
    }
    if (widget.preselectedContacts != null) {
      _selectedContacts = widget.preselectedContacts!;
    }
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    _allContacts = await dbHelper.getContacts();
    setState(() {});
  }

  Future<void> _loadSelectedContacts() async {
    if (widget.note != null) {
      _selectedContacts = await dbHelper.getContactsForNote(widget.note!.id!);
      setState(() {});
    }
  }

  Future<void> _saveNote() async {
    if (_textController.text.isEmpty) return;

    final note = models.Note(
      id: widget.note?.id,
      text: _textController.text,
      date: _selectedDate.toIso8601String(),
      isReminder: _isReminder,
      eventType: _eventType,
    );

    if (widget.note == null) {
      int noteId = await dbHelper.insertNote(note);
      await dbHelper.linkNoteToContacts(noteId, _selectedContacts.map((c) => c.id!).toList());
    } else {
      await dbHelper.updateNote(note);
      await dbHelper.linkNoteToContacts(note.id!, _selectedContacts.map((c) => c.id!).toList());
    }

    Navigator.pop(context);
  }

  void _selectContacts() async {
    final selectedContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactSelector(
          allContacts: _allContacts,
          selectedContacts: _selectedContacts,
          onConfirm: (contacts) {
            setState(() {
              _selectedContacts = contacts;
            });
          },
        ),
      ),
    );

    if (selectedContacts != null) {
      setState(() {
        _selectedContacts = selectedContacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Note'),
            ),
            ListTile(
              title: Text('Date'),
              subtitle: Text(_selectedDate.toLocal().toString()),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate)
                  setState(() {
                    _selectedDate = picked;
                  });
              },
            ),
            SwitchListTile(
              title: Text('Reminder'),
              value: _isReminder,
              onChanged: (bool value) {
                setState(() {
                  _isReminder = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _eventType,
              onChanged: (String? newValue) {
                setState(() {
                  _eventType = newValue!;
                });
              },
              items: <String>['Contact', 'Event', 'Reminder']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _selectContacts,
              child: Text('Select Contacts'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedContacts.length,
                itemBuilder: (context, index) {
                  final contact = _selectedContacts[index];
                  return ListTile(
                    title: Text(contact.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
