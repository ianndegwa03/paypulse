import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ContactsService {
  Future<bool> requestPermission();
  Future<List<Contact>> getContacts();
}

class ContactsServiceImpl implements ContactsService {
  @override
  Future<bool> requestPermission() async {
    // Check permission_handler first for generic permission
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    // Also check flutter_contacts specific permission request if needed
    if (status.isGranted) {
      return await FlutterContacts.requestPermission(readonly: true);
    }

    return status.isGranted;
  }

  @override
  Future<List<Contact>> getContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      return await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
    }
    return [];
  }
}
