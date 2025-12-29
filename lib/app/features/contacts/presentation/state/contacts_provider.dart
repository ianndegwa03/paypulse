import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/services/contacts/contacts_service.dart';

/// Provider that loads contacts from cache first, then syncs from device
final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  final contactsService = getIt<ContactsService>();

  // First, try to load cached contacts for instant display
  final cachedContacts = await contactsService.getCachedContacts();
  if (cachedContacts.isNotEmpty) {
    // Return cached immediately, then refresh in background
    _refreshContactsInBackground(contactsService);
    return cachedContacts;
  }

  // No cache - request permission and sync
  final hasPermission = await contactsService.requestPermission();
  if (hasPermission) {
    return contactsService.getContacts();
  }
  return [];
});

/// Background refresh helper
Future<void> _refreshContactsInBackground(ContactsService service) async {
  try {
    final hasPermission = await service.requestPermission();
    if (hasPermission) {
      await service.getContacts(); // This saves to cache automatically
    }
  } catch (_) {
    // Silently fail background refresh
  }
}

/// Provider to force sync contacts from device
final syncContactsProvider =
    FutureProvider.family<List<Contact>, bool>((ref, forceSync) async {
  final contactsService = getIt<ContactsService>();

  if (!forceSync) {
    return ref.watch(contactsProvider).value ?? [];
  }

  final hasPermission = await contactsService.requestPermission();
  if (hasPermission) {
    final contacts = await contactsService.getContacts();
    // Invalidate the main provider to refresh UI
    ref.invalidate(contactsProvider);
    return contacts;
  }
  return [];
});
