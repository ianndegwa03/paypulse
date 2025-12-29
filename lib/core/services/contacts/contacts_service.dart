import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:paypulse/core/services/local_storage/storage_service.dart';

abstract class ContactsService {
  Future<bool> requestPermission();
  Future<List<Contact>> getContacts();
  Future<void> saveContacts(List<Contact> contacts);
  Future<List<Contact>> getCachedContacts();
  Future<void> clearCachedContacts();
}

class ContactsServiceImpl implements ContactsService {
  final StorageService? _storageService;
  static const String _contactsCacheKey = 'cached_contacts';

  ContactsServiceImpl({StorageService? storageService})
      : _storageService = storageService;

  @override
  Future<bool> requestPermission() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      return await FlutterContacts.requestPermission(readonly: true);
    }

    return status.isGranted;
  }

  @override
  Future<List<Contact>> getContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      final contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);
      // Cache the contacts for persistence
      await saveContacts(contacts);
      return contacts;
    }
    return [];
  }

  @override
  Future<void> saveContacts(List<Contact> contacts) async {
    final storage = _storageService;
    if (storage == null) return;

    try {
      // Convert contacts to a serializable format
      final contactsData = contacts
          .map((c) => {
                'id': c.id,
                'displayName': c.displayName,
                'phones': c.phones
                    .map((p) => {
                          'number': p.number,
                          'label': p.label.name,
                        })
                    .toList(),
                'emails': c.emails
                    .map((e) => {
                          'address': e.address,
                        })
                    .toList(),
                // Store photo as base64 if available
                'photo': c.photo != null ? base64Encode(c.photo!) : null,
              })
          .toList();

      await storage.saveString(_contactsCacheKey, jsonEncode(contactsData));
    } catch (e) {
      // Silently fail - caching is optional
    }
  }

  @override
  Future<List<Contact>> getCachedContacts() async {
    final storage = _storageService;
    if (storage == null) return [];

    try {
      final cachedData = await storage.getString(_contactsCacheKey);
      if (cachedData == null || cachedData.isEmpty) return [];

      final List<dynamic> contactsJson = jsonDecode(cachedData);
      return contactsJson.map((data) {
        final contact = Contact(
          id: data['id'] ?? '',
          displayName: data['displayName'] ?? '',
        );

        // Reconstruct phones
        if (data['phones'] != null) {
          contact.phones = (data['phones'] as List)
              .map((p) => Phone(
                    p['number'] ?? '',
                    label: PhoneLabel.values.firstWhere(
                      (l) => l.name == p['label'],
                      orElse: () => PhoneLabel.mobile,
                    ),
                  ))
              .toList();
        }

        // Reconstruct photo from base64
        if (data['photo'] != null) {
          contact.photo = base64Decode(data['photo']);
        }

        return contact;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearCachedContacts() async {
    final storage = _storageService;
    if (storage == null) return;
    await storage.delete(_contactsCacheKey);
  }
}
