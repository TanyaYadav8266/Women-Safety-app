import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_direct_caller_plugin/flutter_direct_caller_plugin.dart';
import 'package:title_proj/components/PrimaryButton.dart';
import 'package:title_proj/db/db_services.dart';
import 'package:title_proj/model/contactsm.dart';

class AddContactsPage extends StatefulWidget {
  const AddContactsPage({super.key});

  @override
  State<AddContactsPage> createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<TContact>? contactList = [];
  int count = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showList();
    });
  }

  void showList() {
    databaseHelper.getContactList().then((value) {
      setState(() {
        contactList = value;
        count = value.length;
      });
    });
  }

  void deleteContact(TContact contact) async {
    int result = await databaseHelper.deleteContact(contact.id!);
    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact removed successfully");
      showList();
    }
  }

  Future<void> pickContact() async {
    try {
      bool permissionGranted = await FlutterContacts.requestPermission();
      if (!permissionGranted) {
        Fluttertoast.showToast(msg: "Permission denied");
        return;
      }

      final contact = await FlutterContacts.openExternalPick();
      if (contact == null || contact.phones.isEmpty) {
        Fluttertoast.showToast(msg: "No contact selected");
        return;
      }

      String phoneNumber = contact.phones.first.number;
      bool exists = await databaseHelper.contactExists(phoneNumber);

      if (exists) {
        Fluttertoast.showToast(msg: "Contact already exists");
        return;
      }

      TContact newContact = TContact(phoneNumber, contact.displayName);
      await databaseHelper.insertContact(newContact);

      showList();
      Fluttertoast.showToast(msg: "Contact added successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error picking contact: $e");
    }
  }

Future<void> callContact(String number) async {
  try {
    await FlutterDirectCallerPlugin.callNumber(number); // Updated function
  } catch (e) {
    Fluttertoast.showToast(msg: "Failed to call: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            PrimaryButton(title: "Add Trusted Contacts", onPressed: pickContact),
            Expanded(
              child: ListView.builder(
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(contactList![index].name),
                        subtitle: Text(contactList![index].number),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => callContact(contactList![index].number),
                              icon: Icon(Icons.call, color: Colors.red),
                            ),
                            IconButton(
                              onPressed: () => deleteContact(contactList![index]),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
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
