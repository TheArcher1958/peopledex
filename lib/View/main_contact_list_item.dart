import 'dart:convert';
import 'package:flutter/material.dart';
import '../Modal/models.dart' as models;

class MainContactListItem extends StatelessWidget {
  final models.Contact contact;
  final VoidCallback onTap;

  const MainContactListItem({
    Key? key,
    required this.contact,
    required this.onTap,
  }) : super(key: key);

  double _calculateProgress(models.Contact contact) {
    int filledFields = 0;
    if (contact.birthday.isNotEmpty) filledFields++;
    if (contact.phoneNumber.isNotEmpty) filledFields++;
    if (contact.relationship.isNotEmpty) filledFields++;
    if (contact.interests.isNotEmpty) filledFields++;
    if (contact.notes.isNotEmpty) filledFields++;
    if (contact.avatar != null) filledFields++;
    return filledFields / 7;
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _calculateProgress(contact);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: contact.avatar != null
            ? MemoryImage(base64Decode(contact.avatar!))
            : null,
        child: contact.avatar == null ? Icon(Icons.person) : null,
      ),
      title: Text(contact.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contact.phoneNumber),
          LinearProgressIndicator(value: progress),
        ],
      ),
      onTap: onTap,
    );
  }
}
