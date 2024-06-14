import 'package:flutter/material.dart';
import '../Modal/models.dart' as models;

class ContactListItem extends StatelessWidget {
  final models.Contact contact;
  final List<models.Note> notes; // Add notes list
  final VoidCallback onTap;

  ContactListItem({
    required this.contact,
    required this.notes, // Add notes list
    required this.onTap,
  });

  double _calculateProgress() {
    int totalFields = 6; // Total number of fields to consider including notes
    int filledFields = 0;

    if (contact.name.isNotEmpty) filledFields++;
    if (contact.birthday.isNotEmpty) filledFields++;
    // if (contact.relationship.isNotEmpty) filledFields++;
    if (contact.interests.isNotEmpty) filledFields++;
    if (contact.notes.isNotEmpty) filledFields++;
    filledFields += notes.length; // Increment for each note

    return filledFields / totalFields;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contact.birthday),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: _calculateProgress(),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
