import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/contacts/presentation/state/contacts_provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Network',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: contactsAsync.when(
              data: (contacts) {
                final filtered = contacts
                    .where((c) => c.displayName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text("No connections found",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final contact = filtered[index];
                    return _contactTile(context, contact);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(BuildContext context, Contact contact) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/send-money', extra: contact);
        },
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          backgroundImage:
              contact.photo != null ? MemoryImage(contact.photo!) : null,
          child: contact.photo == null
              ? Text(contact.displayName[0],
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold))
              : null,
        ),
        title: Text(contact.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            contact.phones.isNotEmpty
                ? contact.phones.first.number
                : 'No number',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(Icons.send_rounded,
              size: 16, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
