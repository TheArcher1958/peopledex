import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controller/database_helper.dart';
import '../Modal/models.dart';

class AddContactScreen extends StatefulWidget {
  final Contact? contact;

  AddContactScreen({this.contact});

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _birthdayController;
  late TextEditingController _interestsController;
  late TextEditingController _notesController;
  String _relationship = 'Friend'; // Ensure this has a default value from the dropdown list
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _birthdayController = TextEditingController(text: widget.contact?.birthday ?? '');
    _interestsController = TextEditingController(text: widget.contact?.interests ?? '');
    _notesController = TextEditingController(text: widget.contact?.notes ?? '');
    _relationship = widget.contact?.relationship ?? 'Friend';

    if (widget.contact?.birthday != null && widget.contact!.birthday.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.contact!.birthday);
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    // Set the initial relationship value and add debug statements
    if (widget.contact?.relationship != null && widget.contact!.relationship.isNotEmpty) {
      _relationship = widget.contact!.relationship;
    } else {
      _relationship = 'Friend';
    }
    print('Navigated to AddContactScreen with contact: ${widget.contact}');
  }

  @override
  Widget build(BuildContext context) {
    print('Building AddContactScreen');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthdayController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ),
                readOnly: true,
                onTap: _pickDate,
              ),
              DropdownButtonFormField<String>(
                value: _relationship,
                decoration: InputDecoration(labelText: 'Relationship'),
                items: ['Friend', 'Family', 'Colleague', 'Other']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
                  value: label,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _relationship = value!;
                  });
                },
              ),
              TextFormField(
                controller: _interestsController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: 'Interests'),
              ),
              TextFormField(
                controller: _notesController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: Text(widget.contact == null ? 'Save Contact' : 'Update Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      Contact newContact = Contact(
        id: widget.contact?.id,
        name: _nameController.text,
        birthday: _birthdayController.text,
        relationship: _relationship,
        interests: _interestsController.text,
        notes: _notesController.text,
      );

      print('Saving contact: $newContact');

      if (widget.contact == null) {
        print('Inserting new contact');
        await DatabaseHelper().insertContact(newContact);
      } else {
        print('Updating existing contact with id: ${widget.contact!.id}');
        await DatabaseHelper().updateContact(newContact);
      }
      Navigator.pop(context);
      print('Contact saved and navigating back');
    } else {
      print('Form validation failed');
    }
  }

}
