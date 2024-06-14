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
  int? id;
  String text;
  String date;
  bool isReminder;
  String eventType;

  Note({
    this.id,
    required this.text,
    required this.date,
    required this.isReminder,
    required this.eventType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'date': date,
      'isReminder': isReminder ? 1 : 0, // Convert boolean to integer for storage
      'eventType': eventType,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      text: map['text'],
      date: map['date'],
      isReminder: map['isReminder'] == 1, // Convert integer back to boolean
      eventType: map['eventType'],
    );
  }
}


