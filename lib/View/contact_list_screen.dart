import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Controller/database_helper.dart';
import '../Modal/models.dart' as models;
import 'add_contact_screen.dart';
import 'contact_details_screen.dart';
import 'main_contact_list_item.dart'; // Import the new file

class ContactListScreen extends StatefulWidget {
  final ValueNotifier<bool> needsReloadNotifier;

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
    contacts = Future.value([]);
    _loadContacts();
    searchController.addListener(() {
      filterContacts();
    });

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
    Iterable<Contact> phoneContacts = await ContactsService.getContacts(withThumbnails: true);
    for (var phoneContact in phoneContacts) {
      final avatar = phoneContact.avatar != null && phoneContact.avatar!.isNotEmpty
          ? base64Encode(phoneContact.avatar!)
          : null;
      final phoneNumber = phoneContact.phones != null && phoneContact.phones!.isNotEmpty
          ? phoneContact.phones!.first.value ?? ''
          : '';
      models.Contact appContact = models.Contact(
        id: phoneContact.identifier.hashCode,
        name: phoneContact.displayName ?? '',
        birthday: '',
        relationship: '',
        interests: '',
        notes: '',
        phoneNumber: phoneNumber,
        avatar: avatar,
      );
      // print('Contact: ${appContact.name}, Avatar: ${appContact.avatar}'); // Debugging statement
      await dbHelper.insertOrUpdateContact(appContact);
    }
  }


  Future<void> _syncContacts() async {
    await _fetchContactsFromPhone();
    _refreshContacts();
  }

  Future<void> _loadContacts() async {
    await _syncContacts();
    _refreshContacts();
  }

  void _refreshContacts() {
    setState(() {
      contacts = dbHelper.getContacts();
      contacts.then((contactList) {
        allContacts = contactList..sort((a, b) => a.name.compareTo(b.name));
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
    _refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peopledex'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
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
                      return MainContactListItem(
                        contact: contact,
                        onTap: () async {
                          await _navigateToDetails(contact);
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
          widget.needsReloadNotifier.value = true;
          _loadContacts();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
