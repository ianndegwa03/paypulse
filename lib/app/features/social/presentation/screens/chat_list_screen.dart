import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/social/presentation/state/chat_notifier.dart';
import 'package:paypulse/core/services/contacts/contacts_service.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  bool _showGroupCreation = false;
  final Set<Contact> _selectedContacts = {};
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedContacts();
  }

  /// Load cached contacts first for instant display
  Future<void> _loadCachedContacts() async {
    final service = GetIt.I<ContactsService>();
    try {
      // First try to get cached contacts
      final cached = await service.getCachedContacts();
      if (cached.isNotEmpty && mounted) {
        setState(() {
          _contacts = cached;
          _isLoading = false;
        });
        // Refresh in background
        _syncContactsInBackground();
      } else {
        // No cache, sync from device
        await _syncContacts();
      }
    } catch (e) {
      await _syncContacts();
    }
  }

  Future<void> _syncContactsInBackground() async {
    final service = GetIt.I<ContactsService>();
    try {
      final granted = await service.requestPermission();
      if (granted) {
        final contacts = await service.getContacts();
        if (mounted && contacts.isNotEmpty) {
          setState(() => _contacts = contacts);
        }
      }
    } catch (_) {
      // Silently fail background sync
    }
  }

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

  void _openSecureChat(Contact contact) {
    HapticFeedback.lightImpact();
    final chatId = contact.phones.isNotEmpty
        ? contact.phones.first.number.replaceAll(RegExp(r'[^0-9]'), '')
        : 'chat_${contact.id}';

    context.push('/secure-chat/$chatId', extra: {'title': contact.displayName});
  }

  Future<void> _createGroupChat() async {
    if (_selectedContacts.isEmpty || _groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select contacts and enter a group name')),
      );
      return;
    }

    final participantIds = _selectedContacts
        .map((c) => c.phones.isNotEmpty
            ? c.phones.first.number.replaceAll(RegExp(r'[^0-9]'), '')
            : c.id)
        .toList();

    await ref.read(chatNotifierProvider.notifier).createChat(
          participantIds,
          groupName: _groupNameController.text,
        );

    if (mounted) {
      setState(() {
        _showGroupCreation = false;
        _selectedContacts.clear();
        _groupNameController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Group "${_groupNameController.text}" created!')),
      );
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showGroupCreation ? 'New Group' : 'Messages',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_showGroupCreation)
            TextButton(
              onPressed: _createGroupChat,
              child: const Text('Create',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.group_add_rounded),
              tooltip: 'New Group',
              onPressed: () => setState(() => _showGroupCreation = true),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Contacts',
              onPressed: _syncContacts,
            ),
          ],
        ],
        leading: _showGroupCreation
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _showGroupCreation = false;
                  _selectedContacts.clear();
                }),
              )
            : null,
      ),
      body: Column(
        children: [
          // E2E Encryption Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.primary.withOpacity(0.05),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All messages are end-to-end encrypted',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Group Name Input (when creating group)
          if (_showGroupCreation) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: 'Group Name',
                  prefixIcon: const Icon(Icons.group_rounded),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Selected: ${_selectedContacts.length} contacts',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          ],

          // Existing Chats Section
          if (!_showGroupCreation && chatState.chats.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'RECENT CONVERSATIONS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...chatState.chats.take(3).map((chat) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      chat.isGroup ? Icons.group_rounded : Icons.person_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    chat.groupName ?? 'Chat ${chat.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chat.isGroup
                        ? '${chat.participants.length} members'
                        : 'Tap to open',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: chat.unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        )
                      : null,
                  onTap: () => context.push('/secure-chat/${chat.id}',
                      extra: {'title': chat.groupName ?? 'Chat'}),
                )),
            const Divider(),
          ],

          // Contacts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                    ? _buildEmptyState()
                    : _buildContactList(),
          ),
        ],
      ),
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_chat_unread_outlined,
                size: 64, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 32),
          Text(
            'Start a Conversation',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Sync your contacts to find friends on PayPulse and start chatting instantly.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _syncContacts,
              icon: const Icon(Icons.sync),
              label: const Text('Sync Contacts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    final theme = Theme.of(context);

    // Simulate "App Users" logic - in production this would verify against backend
    // For demo: Contacts with photos OR contacts starting with specific letters use app
    final appUsers = _contacts
        .where((c) =>
            c.photo != null ||
            (c.displayName.isNotEmpty &&
                'ABCDE'.contains(c.displayName[0].toUpperCase())))
        .toList();
    final otherContacts =
        _contacts.where((c) => !appUsers.contains(c)).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appUsers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'ON PAYPULSE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: appUsers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildContactTile(appUsers[index], true),
            ),
          ],
          if (otherContacts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'INVITE TO PAYPULSE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: otherContacts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildContactTile(otherContacts[index], false),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactTile(Contact contact, bool isAppUser) {
    final theme = Theme.of(context);
    final isSelected = _selectedContacts.contains(contact);

    return InkWell(
      onTap: () {
        if (_showGroupCreation) {
          setState(() {
            if (isSelected) {
              _selectedContacts.remove(contact);
            } else {
              _selectedContacts.add(contact);
            }
          });
        } else if (isAppUser) {
          _openSecureChat(contact);
        } else {
          // Invite flow
          if (contact.phones.isNotEmpty) {
            final phone = contact.phones.first.number;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Inviting $phone to PayPulse...')),
            );
            // TODO: Implement SMS invite
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isAppUser
                      ? theme.colorScheme.primaryContainer
                      : Colors.grey.shade200,
                  backgroundImage: contact.photo != null
                      ? MemoryImage(contact.photo!)
                      : null,
                  child: contact.photo == null
                      ? Text(
                          contact.displayName.isNotEmpty
                              ? contact.displayName[0]
                              : '?',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isAppUser
                                  ? theme.colorScheme.primary
                                  : Colors.grey))
                      : null,
                ),
                if (_showGroupCreation && isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAppUser
                          ? theme.textTheme.bodyLarge?.color
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isAppUser)
                    Text(
                      'Available',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      contact.phones.isNotEmpty
                          ? contact.phones.first.number
                          : 'No number',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (!_showGroupCreation)
              isAppUser
                  ? Icon(Icons.chat_bubble_outline_rounded,
                      size: 20, color: theme.colorScheme.primary)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'INVITE',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
