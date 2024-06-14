import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Controller/database_helper.dart';
import '../Modal/models.dart' as models;
import 'add_contact_screen.dart';
import 'contact_details_screen.dart';
import 'contact_list_item.dart';
import 'search_bar.dart' as SB;

class ContactListScreen extends StatefulWidget {
  final ValueNotifier<bool> needsReloadNotifier; // Add a ValueNotifier parameter

  ContactListScreen({required this.needsReloadNotifier});

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<models.Contact>> contacts;
  List<models.Contact> allContacts = [];
  List<models.Contact> filteredContacts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    contacts = Future.value([]); // Initialize with an empty list
    _loadContacts();
    searchController.addListener(() {
      filterContacts();
    });

    // Listen to the ValueNotifier for changes
    widget.needsReloadNotifier.addListener(() {
      if (widget.needsReloadNotifier.value) {
        _loadContacts();
        widget.needsReloadNotifier.value = false;
      }
    });
  }

  Future<void> _requestPermission() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus != PermissionStatus.granted) {
      throw Exception('Contacts permission not granted');
    }
  }

  Future<void> _fetchContactsFromPhone() async {
    await _requestPermission();
    Iterable<Contact> phoneContacts = await ContactsService.getContacts();
    for (var phoneContact in phoneContacts) {
      models.Contact appContact = models.Contact(
        id: phoneContact.identifier.hashCode, // Using hashCode as a unique ID
        name: phoneContact.displayName ?? '',
        birthday: '', // Default value, needs to be updated locally
        relationship: '',
        interests: '',
        notes: '',
      );
      await dbHelper.insertOrUpdateContact(appContact);
    }
  }

  Future<void> _syncContacts() async {
    await _fetchContactsFromPhone();
    _refreshContacts();
  }

  Future<void> _loadContacts() async {
    await _syncContacts(); // Sync contacts from phone only if needed
    _refreshContacts();
  }

  void _refreshContacts() {
    setState(() {
      contacts = dbHelper.getContacts();
      contacts.then((contactList) {
        allContacts = contactList;
        filteredContacts = contactList;
      });
    });
  }

  void filterContacts() {
    List<models.Contact> _contacts = [];
    _contacts.addAll(allContacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        return contact.name.toLowerCase().contains(searchTerm);
      });
    }
    setState(() {
      filteredContacts = _contacts;
    });
  }

  Future<void> _navigateToDetails(models.Contact contact) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailsScreen(contact: contact),
      ),
    );
    // After returning from details screen, don't reload contacts from scratch
    _refreshContacts();
  }

  @override
  Widget build(BuildContext context) {

    print('Building ContactListScreen');
    print(widget.needsReloadNotifier.value);

    return Scaffold(
      appBar: AppBar(
        title: Text('Peopledex'),
      ),
      body: Column(
        children: [
          SB.SearchBar(
            controller: searchController,
            onChanged: filterContacts,
          ),
          Expanded(
            child: FutureBuilder<List<models.Contact>>(
              future: contacts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No contacts found.'));
                } else {
                  return ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return FutureBuilder<List<models.Note>>(
                        future: dbHelper.getNotesForContact(contact.id!),
                        builder: (context, noteSnapshot) {
                          if (noteSnapshot.connectionState == ConnectionState.waiting) {
                            return ContactListItem(
                              contact: contact,
                              notes: [],
                              onTap: () async {
                                await _navigateToDetails(contact);
                              },
                            );
                          } else if (noteSnapshot.hasError) {
                            return ContactListItem(
                              contact: contact,
                              notes: [],
                              onTap: () async {
                                await _navigateToDetails(contact);
                              },
                            );
                          } else {
                            return ContactListItem(
                              contact: contact,
                              notes: noteSnapshot.data!,
                              onTap: () async {
                                await _navigateToDetails(contact);
                              },
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContactScreen()),
          );
          // After returning from add contact screen, mark for reload
          widget.needsReloadNotifier.value = true;
          _loadContacts();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
