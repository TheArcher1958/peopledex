import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:peopledex/Modal/models.dart' as models;

import '../Modal/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'peopledex.db');
    return await openDatabase(
      path,
      version: 3, // Increment the version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE contacts (
      id INTEGER PRIMARY KEY,
      name TEXT,
      birthday TEXT,
      relationship TEXT,
      interests TEXT,
      notes TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY,
      text TEXT,
      date TEXT,
      isReminder INTEGER,
      eventType TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE note_contacts (
      noteId INTEGER,
      contactId INTEGER,
      FOREIGN KEY (noteId) REFERENCES notes (id) ON DELETE CASCADE,
      FOREIGN KEY (contactId) REFERENCES contacts (id) ON DELETE CASCADE,
      PRIMARY KEY (noteId, contactId)
    )
  ''');
  }

// In the _onUpgrade method, add the note_contacts table if upgrading from an older version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE contacts ADD COLUMN relationship TEXT DEFAULT "Friend"');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE notes ADD COLUMN eventType TEXT DEFAULT "Contact"');
    }
    if (oldVersion < 4) {  // Assuming the new version is 4
      await db.execute('''
      CREATE TABLE note_contacts (
        noteId INTEGER,
        contactId INTEGER,
        FOREIGN KEY (noteId) REFERENCES notes (id) ON DELETE CASCADE,
        FOREIGN KEY (contactId) REFERENCES contacts (id) ON DELETE CASCADE,
        PRIMARY KEY (noteId, contactId)
      )
    ''');
    }
  }

// Add methods to insert and fetch linked notes and contacts
  Future<void> linkNoteToContacts(int noteId, List<int> contactIds) async {
    final db = await database;
    for (int contactId in contactIds) {
      await db.insert('note_contacts', {
        'noteId': noteId,
        'contactId': contactId,
      });
    }
  }

  Future<List<models.Contact>> getContactsForNote(int noteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT c.* FROM contacts c
    INNER JOIN note_contacts nc ON c.id = nc.contactId
    WHERE nc.noteId = ?
  ''', [noteId]);

    return List.generate(maps.length, (i) {
      return models.Contact.fromMap(maps[i]);
    });
  }

  Future<List<models.Note>> getNotesForContact(int contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT n.* FROM notes n
    INNER JOIN note_contacts nc ON n.id = nc.noteId
    WHERE nc.contactId = ?
  ''', [contactId]);

    return List.generate(maps.length, (i) {
      return models.Note.fromMap(maps[i]);
    });
  }



// Insert a new contact
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

// Get all contacts
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  Future<Contact?> getContactById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }


  Future<int> updateContact(Contact contact) async {
    final db = await database;
    print('Updating contact in database with id: ${contact.id}');
    print('Contact details: ${contact.toMap()}');
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

// Delete a contact
  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Insert a new event
  Future<int> insertEvent(Event event) async {
    final db = await database;
    return await db.insert('events', event.toMap());
  }

// Get all events for a contact
  Future<List<Event>> getEvents(int contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'contactId = ?',
      whereArgs: [contactId],
    );
    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['id'],
        contactId: maps[i]['contactId'],
        event: maps[i]['event'],
        date: maps[i]['date'],
      );
    });
  }

// Update an event
  Future<int> updateEvent(Event event) async {
    final db = await database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

// Delete an event
  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }


  Future<void> insertOrUpdateContact(Contact contact) async {
    final db = await database;
    var result = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contact.id],
    );
    if (result.isEmpty) {
      await insertContact(contact);
    } else {
      Contact existingContact = Contact.fromMap(result.first);
      Contact updatedContact = Contact(
        id: contact.id,
        name: contact.name.isNotEmpty ? contact.name : existingContact.name,
        birthday: contact.birthday.isNotEmpty ? contact.birthday : existingContact.birthday,
        relationship: contact.relationship.isNotEmpty ? contact.relationship : existingContact.relationship,
        interests: contact.interests.isNotEmpty ? contact.interests : existingContact.interests,
        notes: contact.notes.isNotEmpty ? contact.notes : existingContact.notes,
      );
      await updateContact(updatedContact);
    }
  }

}

