import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/services/contacts/contacts_service.dart';

final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  final contactsService = getIt<ContactsService>();
  final hasPermission = await contactsService.requestPermission();
  if (hasPermission) {
    return contactsService.getContacts();
  }
  return [];
});
