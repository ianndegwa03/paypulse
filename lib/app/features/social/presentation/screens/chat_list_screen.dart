import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/core/services/contacts/contacts_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = false;

  Future<void> _syncContacts() async {
    setState(() => _isLoading = true);
    final service = GetIt.I<ContactsService>();
    try {
      final granted = await service.requestPermission();
      if (granted) {
        final contacts = await service.getContacts();
        setState(() => _contacts = contacts);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Permission denied. Cannot sync contacts.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: _contacts.isEmpty ? _buildEmptyState() : _buildContactList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : Icon(Icons.mark_chat_unread_outlined,
                    size: 64, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Messages',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Connect with your friends to start chatting and sharing financial insights securely.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _syncContacts,
              icon: const Icon(Icons.sync),
              label: const Text('Sync Contacts'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                contact.photo != null ? MemoryImage(contact.photo!) : null,
            child: contact.photo == null
                ? Text(contact.displayName.isNotEmpty
                    ? contact.displayName[0]
                    : '?')
                : null,
          ),
          title: Text(contact.displayName),
          subtitle: Text(contact.phones.isNotEmpty
              ? contact.phones.first.number
              : 'No number'),
          onTap: () {
            // Open chat
          },
        );
      },
    );
  }
}
