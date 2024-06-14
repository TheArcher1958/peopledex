import 'package:flutter/material.dart';
import '../Modal/models.dart' as models;

class ContactSelector extends StatefulWidget {
  final List<models.Contact> allContacts;
  final List<models.Contact> selectedContacts;
  final Function(List<models.Contact>) onConfirm;

  ContactSelector({
    required this.allContacts,
    required this.selectedContacts,
    required this.onConfirm,
  });

  @override
  _ContactSelectorState createState() => _ContactSelectorState();
}

class _ContactSelectorState extends State<ContactSelector> {
  TextEditingController _searchController = TextEditingController();
  List<models.Contact> _filteredContacts = [];
  List<models.Contact> _tempSelectedContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.allContacts;
    _tempSelectedContacts = List.from(widget.selectedContacts);
    _searchController.addListener(_filterContacts);
  }

  void _filterContacts() {
    setState(() {
      _filteredContacts = widget.allContacts.where((contact) {
        return contact.name.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  bool _isSelected(models.Contact contact) {
    return _tempSelectedContacts.any((selected) => selected.id == contact.id);
  }

  void _toggleSelection(models.Contact contact) {
    setState(() {
      if (_isSelected(contact)) {
        _tempSelectedContacts.removeWhere((selected) => selected.id == contact.id);
      } else {
        _tempSelectedContacts.add(contact);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onConfirm(_tempSelectedContacts);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Contacts',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                final isSelected = _isSelected(contact);
                return ListTile(
                  title: Text(contact.name),
                  trailing: isSelected
                      ? Icon(Icons.check_box)
                      : Icon(Icons.check_box_outline_blank),
                  onTap: () {
                    _toggleSelection(contact);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
