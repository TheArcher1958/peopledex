import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controller/database_helper.dart';
import '../Modal/models.dart';

class AddNoteScreen extends StatefulWidget {
  final Contact contact;

  AddNoteScreen({required this.contact});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isReminder = false;
  String _eventType = 'Contact'; // Default event type

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      Note newNote = Note(
        contactId: widget.contact.id!,
        text: _textController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        isReminder: _isReminder,
        eventType: _eventType, // Add this line
      );

      await DatabaseHelper().insertNote(newNote);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Note for ${widget.contact.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Note'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a note';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              SwitchListTile(
                title: Text('Is Reminder'),
                value: _isReminder,
                onChanged: (bool value) {
                  setState(() {
                    _isReminder = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _eventType,
                decoration: InputDecoration(labelText: 'Event Type'),
                items: ['Contact', 'Reminder', 'Event']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
                  value: label,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _eventType = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveNote,
                child: Text('Save Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
