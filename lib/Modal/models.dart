class Contact {
  final int? id;
  final String name;
  final String birthday;
  final String relationship;
  final String interests;
  final String notes;

  Contact({
    this.id,
    required this.name,
    required this.birthday,
    required this.relationship,
    required this.interests,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday,
      'relationship': relationship,
      'interests': interests,
      'notes': notes,
    };
  }

  // Factory constructor to handle null values from the database
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'] ?? '',
      birthday: map['birthday'] ?? '',
      relationship: map['relationship'] ?? '',
      interests: map['interests'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}


class Event {
  final int? id;
  final int contactId;
  final String event;
  final String date;

  Event({this.id, required this.contactId, required this.event, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'event': event,
      'date': date,
    };
  }
}

class Note {
  final int? id;
  final int contactId;
  final String text;
  final String date;
  final bool isReminder;
  final String eventType; // Add this line

  Note({
    this.id,
    required this.contactId,
    required this.text,
    required this.date,
    required this.isReminder,
    required this.eventType, // Add this line
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'text': text,
      'date': date,
      'isReminder': isReminder ? 1 : 0,
      'eventType': eventType, // Add this line
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      contactId: map['contactId'],
      text: map['text'] ?? '',
      date: map['date'] ?? '',
      isReminder: map['isReminder'] == 1,
      eventType: map['eventType'] ?? '', // Add this line
    );
  }

}

