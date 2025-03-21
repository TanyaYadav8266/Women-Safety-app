import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:title_proj/db/db_services.dart';
import 'package:title_proj/model/contactsm.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<TContact>? contactList;
  int count = 0;

  void showList() {
    _databaseHelper.getContactList().then((value) {
      setState(() {
        contactList = value;
        count = value.length;
      });
    });
  }

  void deleteContact(TContact contact) async {
    int result = await _databaseHelper.deleteContact(contact.id);
    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact removed successfully");
      showList();
    }
  }

  Future<void> pickContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String phoneNumber = contact.phones.first.number;

        // ✅ Check if contact already exists before inserting
        bool exists = await _databaseHelper.contactExists(phoneNumber);
        if (exists) {
          Fluttertoast.showToast(msg: "Contact already exists");
          return;
        }

        TContact newContact = TContact(phoneNumber, contact.displayName);
        await _databaseHelper.insertContact(newContact);
        showList();
      }
    } else {
      Fluttertoast.showToast(msg: "Permission denied");
    }
  }

  @override
  void initState() {
    super.initState();
    showList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickContact,
              child: Text("Add Trusted Contacts"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Text(contactList![index].name),
                      subtitle: Text(contactList![index].number),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await FlutterContacts.openExternalEdit(
                                  contactList![index].id.toString());
                            },
                            icon: Icon(Icons.call, color: Colors.green),
                          ),
                          IconButton(
                            onPressed: () {
                              deleteContact(contactList![index]);
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
