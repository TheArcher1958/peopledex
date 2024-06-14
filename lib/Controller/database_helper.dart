import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:peopledex/Modal/models.dart';

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
      contactId INTEGER,
      text TEXT,
      date TEXT,
      isReminder INTEGER,
      eventType TEXT,
      FOREIGN KEY (contactId) REFERENCES contacts (id)
    )
  ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE contacts ADD COLUMN relationship TEXT DEFAULT "Friend"');
    }
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY,
        contactId INTEGER,
        text TEXT,
        date TEXT,
        isReminder INTEGER,
        eventType TEXT,
        FOREIGN KEY (contactId) REFERENCES contacts (id)
      )
    ''');
    } else {
      // If table already exists, add the column
      await db.execute('ALTER TABLE notes ADD COLUMN eventType TEXT DEFAULT "Contact"');
    }
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

  Future<List<Note>> getNotesForContact(int contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'contactId = ?',
      whereArgs: [contactId],
    );
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
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

