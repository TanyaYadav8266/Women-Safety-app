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
      Fluttertoast.showToast(
        msg: "Contact removed successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      showList();
    }
  }

  Future<void> pickContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String phoneNumber = contact.phones.first.number;

        bool exists = await _databaseHelper.contactExists(phoneNumber);
        if (exists) {
          Fluttertoast.showToast(
            msg: "Contact already exists",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
          );
          return;
        }

        TContact newContact = TContact(phoneNumber, contact.displayName);
        await _databaseHelper.insertContact(newContact);
        showList();
      }
    } else {
      Fluttertoast.showToast(
        msg: "Permission denied",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    showList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Trusted Contacts',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple[700]!, Colors.purple[500]!],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: Colors.purple),
                title: Text('Trusted Contacts',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('These contacts will receive emergency alerts'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickContact,
              icon: Icon(Icons.person_add_alt_1, size: 20),
              label: Text('ADD TRUSTED CONTACT',
                  style: TextStyle(fontSize: 14, letterSpacing: 0.5)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.purple[600],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: count == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.contacts, size: 60, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text('No trusted contacts yet',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600])),
                          SizedBox(height: 8),
                          Text('Add contacts to get started',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: count,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple[100],
                              child: Icon(Icons.person, color: Colors.purple[600]),
                            ),
                            title: Text(contactList![index].name,
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(contactList![index].number),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    await FlutterContacts.openExternalEdit(
                                        contactList![index].id.toString());
                                  },
                                  icon: Icon(Icons.call,
                                      color: Colors.green[600]),
                                  tooltip: 'Call',
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Remove Contact'),
                                          content: Text(
                                              'Are you sure you want to remove ${contactList![index].name}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteContact(contactList![index]);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Remove',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.delete,
                                      color: Colors.red[600]),
                                  tooltip: 'Delete',
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